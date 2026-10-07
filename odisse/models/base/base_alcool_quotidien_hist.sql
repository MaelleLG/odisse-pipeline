-- Consommation quotidienne d'alcool, Baromètres santé 2000-2021 (régions)
-- Format source « large » : une colonne par mesure (_v valeur, _icb / _ich bornes de l'IC, _typo comparaison régionale)
with source as (
    select * from {{ source('odisse', 'alcool-consommation-quotidienne-region') }}
),

renamed as (
    select
        -- identification
        'alcool-consommation-quotidienne-region' as source_id,
        'Consommation quotidienne d''alcool' as indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,              -- Hommes et Femmes / Hommes / Femmes
        try_cast(reg as integer) as code_region,
        -- mesures
        alc_quo_v as valeur,
        alc_quo_icb as ic_inf,
        alc_quo_ich as ic_sup,
        alc_quo_typo as classification   -- A inférieur / B pas de différence / C supérieur aux autres régions
    from source
)

select * from renamed
