-- Épisode dépressif caractérisé au cours des 12 derniers mois, Baromètres santé 2005-2021 (régions)
with source as (
    select * from {{ source('odisse', 'sante-mentale-episodes-depressifs-caracterises-dans-les-12-derniers-mois_reg') }}
),

renamed as (
    select
        -- identification
        'sante-mentale-episodes-depressifs-caracterises-dans-les-12-derniers-mois_reg' as source_id,
        'Episode dépressif caractérisé au cours des 12 derniers mois' as indicateur,
        '%' as unite,
        year(annee) as annee,
        -- dimensions
        sexe,
        try_cast(reg as integer) as code_region,
        -- mesures
        taux_depisodes_depressifs_12_derniers_mois as valeur,
        borne_inferieure_de_lintervalle_de_confiance_du_taux_depisodes_depressifs_au_cours_des_12_derniers_m as ic_inf,
        borne_superieure_de_lintervalle_de_confiance_du_taux_depisodes_depressifs_au_cours_des_12_derniers_m as ic_sup,
        edc_typo as classification
    from source
)

select * from renamed
