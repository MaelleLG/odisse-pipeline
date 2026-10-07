-- Activité physique (loisirs + mobilités domicile-travail), Baromètre 2024
-- Région fournie en code INSEE ; le libellé (reglib) sera repris du seed ref_regions.
with source as (
    select * from {{ source('odisse', 'activite-physique-indicateurs-du-barometre-de-sante-publique-detail-region') }}
),

renamed as (
    select
        -- identification
        'activite-physique-indicateurs-du-barometre-de-sante-publique-detail-region' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        classe_d_age,
        try_cast(nouvelles_regions as integer) as code_region,
        -- mesures
        estimation as valeur,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif
    from source
)

select * from renamed
