with source as (
    select * from {{ source('odisse', 'bien-etre-indicateurs-du-barometre-2024') }}
),

renamed as (
    select
        -- identification
        'bien-etre-indicateurs-du-barometre-2024' as source_id,
        indicateur,
        '/10' as unite,
        -- dimensions
        year(annee) as annee,
        sexe,
        classe_d_age,
        nouvelles_regions as region_libelle,
        pcs,
        type_de_menage,
        situation_professionnelle,
        situation_financiere_percue,
        diplome,
        -- mesures
        cast(effectif_brut as int) as effectif,
        estimation as valeur,
        ic_inf,
        ic_sup,
        classification
    from source
)

select * from renamed