
SELECT
    wv.id,
    u.email AS "userEmail",
    wv."leftVolume",
    wv."rightVolume",
    wv."paidAmount" AS "commissionEarned",
    wv."weekStartDate",
    wv."weekEndDate",
    wv.status,
    wv."selectedSide",
    wv."createdAt" AS "processedAt",
    wv."createdAt",
    COALESCE(
                    JSON_AGG(
                    JSON_BUILD_OBJECT(
                            'volumeSide', wvh."selectedSide",
                            'volume', wvh.volume,
                            'createdAt', wvh."createdAt",
                            'updatedAt', wvh."updatedAt",
                            'payment_id', wvh.payment_id
                    ) ORDER BY wvh."createdAt"
                            ) FILTER (WHERE wvh.id IS NOT NULL),
                    '[]'::json
    ) AS history
FROM
    weekly_volumes wv
        INNER JOIN users u ON wv.user_id = u.id
        LEFT JOIN weekly_volumes_history wvh ON wv.id = wvh.weekly_volume_id
GROUP BY
    wv.id,
    u.email,
    wv."leftVolume",
    wv."rightVolume",
    wv."paidAmount",
    wv."weekStartDate",
    wv."weekEndDate",
    wv.status,
    wv."selectedSide",
    wv.metadata,
    wv."createdAt"
ORDER BY
    wv."createdAt" DESC;