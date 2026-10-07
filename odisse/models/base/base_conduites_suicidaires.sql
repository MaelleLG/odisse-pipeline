-- Pensées suicidaires (12 mois) et tentatives de suicide (vie entière), Baromètre 2024
-- estimation = -30 : valeur masquée par Santé publique France (effectif trop faible)
with source as (
    select * from {{ source('odisse', 'conduites-suicidaires-indicateurs-du-barometre-de-sante-publique-france-2024-detail-region') }}
),

renamed as (
    select
        -- identification
        'conduites-suicidaires-indicateurs-du-barometre-de-sante-publique-france-2024-detail-region' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        classe_d_age,
        try_cast(nouvelles_regions as integer) as code_region,
        -- mesures
        case when estimation < 0 then null else estimation end as valeur,
        estimation < 0 as est_masque,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif
    from source
)

select * from renamed
