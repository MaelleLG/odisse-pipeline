-- Diabète déclaré et traitement du diabète, Baromètre 2024
-- estimation = -30 : valeur masquée. Les lignes "Traitement du diabète" ont des dimensions vides
-- (région, âge...) : elles concernent la France entière ; à harmoniser en intermediate.
with source as (
    select * from {{ source('odisse', 'diabete-indicateurs-du-barometre-2024') }}
),

renamed as (
    select
        -- identification
        'diabete-indicateurs-du-barometre-2024' as source_id,
        indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        classe_d_age,
        nouvelles_regions as region_libelle,
        pcs,
        diplome,
        situation_professionnelle,
        situation_financiere_percue,
        -- dimension propre à ce jeu
        anciennete_du_diabete,
        -- mesures
        case when estimation < 0 then null else estimation end as valeur,
        estimation < 0 as est_masque,
        ic_inf,
        ic_sup,
        cast(effectif_brut as integer) as effectif,
        classification
    from source
)

select * from renamed
