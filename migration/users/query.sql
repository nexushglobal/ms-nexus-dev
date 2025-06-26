SELECT 
    u.id as user_id,
    u.email,
    u.password,
    u."referralCode",
    u."referrerCode",
    u.position,
    u."isActive",
    u."createdAt" as user_created_at,
    u."updatedAt" as user_updated_at,
    pi."firstName",
    pi."lastName",
    pi.gender,
    pi."birthDate",
    ci.phone,
    r.code as role_code,
    u.parent_id,
    u.nickname,
    u.photo,
    ci.address as contact_address,
    ci."postalCode",
    bki."bankName",
    bki."accountNumber",
    bki.cci,
    bi.address as billing_address,
    u."lastLoginAt",
    pi."documentNumber"

FROM users u
LEFT JOIN personal_info pi ON u.id = pi.user_id
LEFT JOIN contact_info ci ON u.id = ci.user_id
LEFT JOIN billing_info bi ON u.id = bi.user_id
LEFT JOIN bank_info bki ON u.id = bki.user_id
LEFT JOIN roles r ON u."roleId" = r.id

ORDER BY u."createdAt" DESC;