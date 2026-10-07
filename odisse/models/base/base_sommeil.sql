with source as (
    select * from {{ source('odisse', 'sommeil-indicateurs-du-barometre-2024') }}
),

renamed as (
    select
        -- identification
        'sommeil-indicateurs-du-barometre-2024' as source_id,
        indicateur,
        case when indicateur = 'Temps de sommeil moyen sur 24 heures' 
        then 'minutes'
        else '%' 
        end as unite,
        -- dimensions
        year(annee) as annee,
        sexe,
        classe_d_age,
        nouvelles_regions as region_libelle,
        pcs_en_5_classes as pcs,
        type_de_menage_impute as type_de_menage,
        situation_financiere_percue,
        diplome,
        -- mesures
        cast(effectif_brut as int) as effectif,
        case when indicateur = 'Temps de sommeil moyen sur 24 heures' 
            then cast(split_part(estimation,'h',1) as int)*60+cast(split_part(estimation,'h',2) as int) 
            else cast(estimation as double)
            end as valeur,
        ic_inf,
        ic_sup,
        classification
    from source
)

select * from renamed