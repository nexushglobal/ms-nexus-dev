SELECT
    m.id as membership_id,
    u.email as userEmail,
    mp.id as plan_id,
    mp.name as plan,
    m."startDate",
    m."endDate",
    m.status,
    m."minimumReconsumptionAmount",
    m."autoRenewal",
    m."createdAt",
    m."updatedAt",
    -- Subconsulta para obtener las reconsumptions como JSON
    COALESCE(
            (SELECT json_agg(
                            json_build_object(
                                    'id', mr.id,
                                    'amount', mr.amount,
                                    'status', mr.status,
                                    'periodDate', mr."periodDate",
                                    'paymentReference', mr."paymentReference",
                                    'paymentDetails', mr."paymentDetails",
                                    'notes', mr.notes,
                                    'createdAt', mr."createdAt",
                                    'updatedAt', mr."updatedAt"
                            )
                    )
             FROM membership_reconsumptions mr
             WHERE mr.membership_id = m.id),
            '[]'::json
    ) as reconsumptions,
    -- Subconsulta para obtener el membership_history como JSON
    COALESCE(
            (SELECT json_agg(
                            json_build_object(
                                    'id', history_data.id,
                                    'action', history_data.action,
                                    'changes', history_data.changes,
                                    'notes', history_data.notes,
                                    'metadata', history_data.metadata,
                                    'createdAt', history_data."createdAt"
                            ) ORDER BY history_data."createdAt" DESC
                    )
             FROM (
                      SELECT
                          mh.id,
                          mh.action,
                          mh.changes,
                          mh.notes,
                          mh.metadata,
                          mh."createdAt"
                      FROM membership_history mh
                      WHERE mh.membership_id = m.id
                  ) as history_data),
            '[]'::json
    ) as membership_history
FROM memberships m
         INNER JOIN users u ON m.user_id = u.id
         INNER JOIN membership_plans mp ON m.plan_id = mp.id