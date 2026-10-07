-- Alcool, Baromètre 2024
with source as (
    select * from {{ source('odisse', 'alcool-indicateurs-du-barometre-de-sante-publique-france-2024-detail-region') }}
),

renamed as (
    select
        -- identification
        'alcool-indicateurs-du-barometre-de-sante-publique-france-2024-detail-region' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        classe_d_age,
        try_cast(nouvelles_regions as integer) as code_region,
        pcs,
        diplome,
        situation_financiere_percue,
        -- dimension propre à ce jeu : ventile l'indicateur "envie de réduire" selon le dépassement des repères
        depassement_des_reperes_de_consommation_d_alcool as depassement_reperes,
        -- mesures
        estimation as valeur,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif
    from source
)

select * from renamed
