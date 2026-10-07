-- Troubles probables de santé mentale des enfants du CP au CM2, enquête Enabee 2022
-- Population différente (6-11 ans), France entière uniquement, pas de région.
with source as (
    select * from {{ source('odisse', 'troubles-probables-de-sante-mentale-parmi-les-enfants-du-cp-au-cm2-indicateurs-d-enabee-2022') }}
),

renamed as (
    select
        -- identification
        'troubles-probables-de-sante-mentale-parmi-les-enfants-du-cp-au-cm2-indicateurs-d-enabee-2022' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,              -- Tous / Fille / Garçon
        niveau_scolaire,   -- Tous / CP ... CM2
        -- mesures
        estimation as valeur,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif
    from source
)

select * from renamed
