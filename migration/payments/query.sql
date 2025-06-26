SELECT
    p.id,
    u.email as "userEmail",
    p.payment_config_id as "paymentConfigId",
    p.amount,
    p.status,
    p."methodPayment" as "paymentMethod",
    p."codeOperation" as "operationCode",
    p."numberTicket" as "ticketNumber",
    p."rejectionReason",
    COALESCE(payment_images.items, '[]'::json) as "items",
    p.reviewed_by_id as "reviewedById",
    reviewer.email as "reviewedByEmail",
    p."reviewedAt",
    p."isArchived",
    p."relatedEntityType",
    p."relatedEntityId",
    p.metadata,
    p."createdAt",
    p."updatedAt"
FROM
    payments p
        INNER JOIN users u ON p.user_id = u.id
        LEFT JOIN users reviewer ON p.reviewed_by_id = reviewer.id
        LEFT JOIN (
        SELECT
            payment_id,
            JSON_AGG(
                    JSON_BUILD_OBJECT(
                            'id', id,
                            'url', url,
                            'cloudinaryPublicId', "cloudinaryPublicId",
                            'amount', amount,
                            'bankName', "bankName",
                            'transactionReference', "transactionReference",
                            'transactionDate', "transactionDate",
                            'isActive', "isActive",
                            'createdAt', "createdAt",
                            'updatedAt', "updatedAt"
                    )
            ) as items
        FROM payment_images
        WHERE "isActive" = true
        GROUP BY payment_id
    ) payment_images ON p.id = payment_images.payment_id
ORDER BY
    p."createdAt" DESC;