-- Alcoolisations ponctuelles importantes (API), Baromètres santé 2005-2021 (régions)
-- Source « large » à 3 mesures, remise au format long (une ligne par indicateur) :
--   alc_bim      : API mensuelle, tous âges
--   alc_bim_1830 : API mensuelle chez les 18-30 ans -> même indicateur, classe d'âge '18-30 ans'
--   alc_bis      : API hebdomadaire (non publiée en 2021)
with source as (
    select * from {{ source('odisse', 'alcool-alcoolisation-ponctuelle-importante-api-mensuel-et-hebdomadaire-region') }}
),

api_mensuelle as (
    select
        annee, sexe, reg,
        'Alcoolisation ponctuelle importante mensuelle' as indicateur,
        'Tous' as classe_d_age,
        alc_bim_v as valeur, alc_bim_icb as ic_inf, alc_bim_ich as ic_sup, alc_bim_typo as classification
    from source
),

api_mensuelle_18_30 as (
    select
        annee, sexe, reg,
        'Alcoolisation ponctuelle importante mensuelle' as indicateur,
        '18-30 ans' as classe_d_age,
        alc_bim_1830_v, alc_bim_1830_icb, alc_bim_1830_ich, alc_bim_1830_typo
    from source
),

api_hebdomadaire as (
    select
        annee, sexe, reg,
        'Alcoolisation ponctuelle importante hebdomadaire' as indicateur,
        'Tous' as classe_d_age,
        alc_bis_v, alc_bis_icb, alc_bis_ich, alc_bis_typo
    from source
),

unioned as (
    -- union all aligne les colonnes par position : l'ordre doit être identique dans les 3 CTE
    select * from api_mensuelle
    union all
    select * from api_mensuelle_18_30
    union all
    select * from api_hebdomadaire
),

renamed as (
    select
        -- identification
        'alcool-alcoolisation-ponctuelle-importante-api-mensuel-et-hebdomadaire-region' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        classe_d_age,
        try_cast(reg as integer) as code_region,
        -- mesures
        valeur,
        ic_inf,
        ic_sup,
        classification
    from unioned
    where valeur is not null   -- mesures non publiées certaines années (ex. API hebdo en 2021)
)

select * from renamed
