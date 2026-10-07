-- Prévalence du diabète traité pharmacologiquement, SNDS 2010-2023 (régions)
-- Deux mesures remises au format long : taux standardisé (comparable entre régions) et taux brut.
with source as (
    select * from {{ source('odisse', 'diabete-prevalence-region') }}
),

taux_standardise as (
    select annee, sexe, reg,
        'Diabète traité (taux standardisé)' as indicateur,
        diabete_tx_std as valeur
    from source
),

taux_brut as (
    select annee, sexe, reg,
        'Diabète traité (taux brut)' as indicateur,
        diabete_tx_brut
    from source
),

unioned as (
    select * from taux_standardise
    union all
    select * from taux_brut
),

renamed as (
    select
        -- identification
        'diabete-prevalence-region' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        try_cast(reg as integer) as code_region,
        -- mesures (pas d'intervalle de confiance : données exhaustives, pas une enquête)
        valeur
    from unioned
)

select * from renamed
