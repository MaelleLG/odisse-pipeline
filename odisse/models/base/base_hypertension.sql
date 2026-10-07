-- Hypertension artérielle déclarée et traitement, Baromètre 2024
with source as (
    select * from {{ source('odisse', 'hypertension-arterielle-indicateurs-du-barometre-2024') }}
),

renamed as (
    select
        -- identification
        'hypertension-arterielle-indicateurs-du-barometre-2024' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        classe_d_age,
        nouvelles_regions as region_libelle,
        pcs,
        diplome,
        situation_financiere_percue,
        -- mesures
        estimation as valeur,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif,
        classification
    from source
)

select * from renamed
