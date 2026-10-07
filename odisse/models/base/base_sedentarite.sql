-- Sédentarité, Baromètre 2024
with source as (
    select * from {{ source('odisse', 'sedentarite-indicateurs-du-barometre-de-sante-publique-france-2024-detail-region') }}
),

renamed as (
    select
        -- identification
        'sedentarite-indicateurs-du-barometre-de-sante-publique-france-2024-detail-region' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        -- la source laisse classe_d_age vide (au lieu de 'Tous') quand l'âge n'est pas ventilé
        coalesce(classe_d_age, 'Tous') as classe_d_age,
        try_cast(nouvelles_regions as integer) as code_region,
        pcs,
        diplome,
        situation_financiere_percue,
        -- mesures
        estimation as valeur,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif
    from source
)

select * from renamed
