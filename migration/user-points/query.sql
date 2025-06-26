SELECT
    up.id,
    up."availablePoints",
    up."totalEarnedPoints",
    up."totalWithdrawnPoints",
    u.email AS "userEmail",
    COALESCE(
                    JSON_AGG(
                    CASE
                        WHEN pt.id IS NOT NULL THEN
                            JSON_BUILD_OBJECT(
                                    'id', pt.id,
                                    'amount', pt.amount,
                                    'status', pt.status,
                                    'metadata', pt.metadata,
                                    'pendingAmount', pt."pendingAmount",
                                    'withdrawnAmount', pt."withdrawnAmount",
                                    'isArchived', pt."isArchived",
                                    'type', pt.type,
                                    'createdAt', pt."createdAt",
                                    'payments', COALESCE(payments_agg.payments, '[]'::json)
                            )
                        ELSE NULL
                        END
                            ) FILTER (WHERE pt.id IS NOT NULL),
                    '[]'::json
    ) AS transactions
FROM
    public.user_points up
        INNER JOIN public.users u ON up.user_id = u.id
        LEFT JOIN public.points_transactions pt ON up.user_id = pt.user_id
        LEFT JOIN (
        SELECT
            ptp.points_transaction_id,
            JSON_AGG(
                    JSON_BUILD_OBJECT(
                            'points_transaction_id', ptp.points_transaction_id,
                            'payment_id', ptp.payment_id,
                            'createdAt', ptp."createdAt",
                            'updatedAt', ptp."updatedAt"
                    )
            ) AS payments
        FROM
            public.points_transactions_payments ptp
        GROUP BY
            ptp.points_transaction_id
    ) payments_agg ON pt.id = payments_agg.points_transaction_id
GROUP BY
    up.id,
    up."availablePoints",
    up."totalEarnedPoints",
    up."totalWithdrawnPoints",
    u.email
ORDER BY
    up.id;