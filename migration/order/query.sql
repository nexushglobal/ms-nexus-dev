SELECT
    pc.id,
    pc.name,
    pc.description,
    pc.code,
    pc."order",
    pc."isActive",
    pc."createdAt",
    pc."updatedAt",
    COALESCE(
                    JSON_AGG(
                    CASE
                        WHEN p.id IS NOT NULL THEN
                            JSON_BUILD_OBJECT(
                                    'id', p.id,
                                    'name', p.name,
                                    'description', p.description,
                                    'composition', p.composition,
                                    'memberPrice', p."memberPrice",
                                    'publicPrice', p."publicPrice",
                                    'stock', p.stock,
                                    'status', p.status,
                                    'benefits', p.benefits,
                                    'sku', p.sku,
                                    'isActive', p."isActive",
                                    'createdAt', p."createdAt",
                                    'updatedAt', p."updatedAt",
                                    'images', COALESCE(images_agg.images, '[]'::json),
                                    'stockHistory', COALESCE(stock_history_agg.stock_history, '[]'::json)
                            )
                        ELSE NULL
                        END
                            ) FILTER (WHERE p.id IS NOT NULL),
                    '[]'::json
    ) AS products
FROM
    public.product_categories pc
        LEFT JOIN public.products p ON pc.id = p."categoryId"
        LEFT JOIN (
        SELECT
            pi."productId",
            JSON_AGG(
                    JSON_BUILD_OBJECT(
                            'id', pi.id,
                            'url', pi.url,
                            'cloudinaryPublicId', pi."cloudinaryPublicId",
                            'isMain', pi."isMain",
                            'order', pi."order",
                            'isActive', pi."isActive",
                            'createdAt', pi."createdAt",
                            'updatedAt', pi."updatedAt"
                    )
                    ORDER BY pi."order", pi.id
            ) AS images
        FROM
            public.product_images pi
        GROUP BY
            pi."productId"
    ) images_agg ON p.id = images_agg."productId"
        LEFT JOIN (
        SELECT
            psh.product_id,
            JSON_AGG(
                    JSON_BUILD_OBJECT(
                            'id', psh.id,
                            'actionType', psh."actionType",
                            'previousQuantity', psh."previousQuantity",
                            'newQuantity', psh."newQuantity",
                            'quantityChanged', psh."quantityChanged",
                            'notes', psh.notes,
                            'createdAt', psh."createdAt",
                            'updatedBy', CASE
                                             WHEN psh.updated_by_id IS NOT NULL THEN
                                                 JSON_BUILD_OBJECT(
                                                         'userId', u.id,
                                                         'userEmail', u.email,
                                                         'userName', COALESCE(
                                                                 CONCAT(pi."firstName", ' ', pi."lastName"),
                                                                 u.nickname,
                                                                 u.email
                                                                     )
                                                 )
                                             ELSE NULL
                                END
                    )
                    ORDER BY psh."createdAt" DESC
            ) AS stock_history
        FROM
            public.product_stock_history psh
                LEFT JOIN public.users u ON psh.updated_by_id = u.id
                LEFT JOIN public.personal_info pi ON u.id = pi.user_id
        GROUP BY
            psh.product_id
    ) stock_history_agg ON p.id = stock_history_agg.product_id
GROUP BY
    pc.id,
    pc.name,
    pc.description,
    pc.code,
    pc."order",
    pc."isActive",
    pc."createdAt",
    pc."updatedAt"
ORDER BY
    pc."order", pc.id;