-- Surpoids et obésité (mesurés), étude Esteban 2015-2017 (régions)
-- Période pluriannuelle : annee = dernière année de la période, periode garde le libellé d'origine.
with source as (
    select * from {{ source('odisse', 'corpulence-surpoids-et-obesite-reg') }}
),

surpoids as (
    select annee, sexe_hf, reg,
        'Surpoids (obésité incluse)' as indicateur,
        surpoids as valeur, surpoids_inf as ic_inf, surpoids_sup as ic_sup
    from source
),

obesite as (
    select annee, sexe_hf, reg,
        'Obésité' as indicateur,
        obesite, obesite_inf, obesite_sup
    from source
),

unioned as (
    select * from surpoids
    union all
    select * from obesite
),

renamed as (
    select
        -- identification
        'corpulence-surpoids-et-obesite-reg' as source_id,
        indicateur,
        '%' as unite,
        cast(split_part(annee, '-', 2) as integer) as annee,
        annee as periode,
        -- dimensions
        sexe_hf as sexe,   -- Hommes / Femmes (pas de valeur « ensemble » dans la source)
        try_cast(reg as integer) as code_region,
        -- mesures
        valeur,
        ic_inf,
        ic_sup
    from unioned
    where valeur is not null   -- certaines régions non publiées
)

select * from renamed
