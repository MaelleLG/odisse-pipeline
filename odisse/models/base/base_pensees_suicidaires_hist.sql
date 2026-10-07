-- Pensées suicidaires et tentatives de suicide, Baromètres santé 2005-2021 (régions)
-- Source « large » à 3 mesures, remise au format long. Les valeurs sont stockées en texte dans la source.
with source as (
    select * from {{ source('odisse', 'sante-mentale-pensees-suicidaires-et-tentatives-de-suicide_reg') }}
),

pensees_12m as (
    select annee, sexe, reg,
        'Pensées suicidaires au cours des 12 derniers mois' as indicateur,
        ps_12m_v as valeur, ps_12m_icb as ic_inf, ps_12m_ich as ic_sup, ps_12m_typo as classification
    from source
),

tentatives_12m as (
    select annee, sexe, reg,
        'Tentative de suicide au cours des 12 derniers mois' as indicateur,
        ts_12m_v, ts_12m_icb, ts_12m_ich, ts_12m_typo
    from source
),

tentatives_vie as (
    select annee, sexe, reg,
        'Tentative de suicide au cours de la vie' as indicateur,
        ts_vie_v, ts_vie_icb, ts_vie_ich, ts_vie_typo
    from source
),

unioned as (
    select * from pensees_12m
    union all
    select * from tentatives_12m
    union all
    select * from tentatives_vie
),

renamed as (
    select
        -- identification
        'sante-mentale-pensees-suicidaires-et-tentatives-de-suicide_reg' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        try_cast(reg as integer) as code_region,
        -- mesures (texte -> nombre)
        try_cast(valeur as double) as valeur,
        try_cast(ic_inf as double) as ic_inf,
        try_cast(ic_sup as double) as ic_sup,
        classification
    from unioned
    where try_cast(valeur as double) is not null
)

select * from renamed
