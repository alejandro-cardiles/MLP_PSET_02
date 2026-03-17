# MLP_PSET_02



<!-------------------------->
<!-------------------------->
<!-------------------------->
## 1. ¿Qué es este repositorio?

Este repositorio contiene el flujo completo de trabajo para analizar la relación entre gasto militar y desempeño económico. Incluye:

- Recolección y limpieza de datos  
- Construcción de variables  
- Análisis descriptivo  
- Estimaciones econométricas  
- Exportación de resultados en formato listo para LaTeX  

El proyecto está organizado de forma modular para facilitar replicabilidad y extensión.

<!-------------------------->
<!-------------------------->
<!-------------------------->

## 2. Descripción de carpetas


<!-------------------------->
###  00_literatura
Contiene los artículos y documentos académicos utilizados como base teórica del proyecto.  
Sirve como referencia conceptual para la construcción de hipótesis y la interpretación de resultados.


<!-------------------------->
###  01_data

Carpeta encargada de la **ingesta, limpieza y estandarización de datos por fuente**.

#### input/

Contiene los datos originales sin procesar.

- MIDB 5.0.csv → conflictos  
- pwt110.xlsx → Penn World Tables  
- SIPRI-Milex-data-1949-2025.xlsx → gasto militar  

#### output/

Contiene los datos ya limpiados y estandarizados por fuente.  
Estos archivos son utilizados como insumo para la construcción del dataset final.

- 01_pwt.rds → datos procesados de Penn World Tables  
- 02_SIPRI.rds → datos procesados de gasto militar (SIPRI)  
- 03_midb.rds → datos procesados de conflictos (MIDB) 

#### scr/

Scripts encargados de procesar cada fuente de datos de manera independiente.

- 01_pwt.R → limpieza y transformación de PWT  
- 02_sipri.R → limpieza y transformación de SIPRI  
- 03_midb.R → limpieza y transformación de MIDB  

<!-------------------------->
###  02_prepare_data

Carpeta encargada de la **construcción del dataset analítico final** a partir de las fuentes limpias.

#### scr/
- 01_join_data.R  → une las bases limpias en un solo dataset consistente a nivel país-año  

#### output/
- 01_data_gdp_war.rds → dataset final listo para análisis econométrico  

<!-------------------------->
###  03_regressions

Contiene la implementación de los **modelos econométricos del proyecto**.

#### scr/

- 01_main_reg.R → especificación principal  
- 02_main_mecanismo.R → análisis de mecanismos  

#### output/

Resultados exportados en formato LaTeX, listos para ser incluidos en el documento final.

- 01_tabla_reg_principal.tex  
- 02_tabla_reg_mecanismo.tex  

<!-------------------------->
###  04_descriptive

Genera **estadísticas descriptivas y visualizaciones** para explorar los datos.

#### scr/

- 01_share_gdp_vs_conflict.R → construcción de gráfico descriptivo  

#### output/

- 01_share_gdp_vs_conflict.png → visualización generada  

<!-------------------------->
### Archivos raíz

Archivos de control del pipeline:

- 00_packages.R → instalación y carga de librerías necesarias  
- RUNME.R → script maestro que ejecuta todo el flujo de trabajo  
- README.md → documentación del repositorio  

<!-------------------------->
<!-------------------------->
<!-------------------------->

## 3. Estructura del repositorio 

```bash
MLP_PSET_02/
│
├── 00_literatura/
│   ├── *.pdf
│
├── 01_data/
│   ├── input/
│   │   ├── MIDB 5.0.csv
│   │   ├── pwt110.xlsx
│   │   └── SIPRI-Milex-data-1949-2025.xlsx
│   ├── output/
│   └── scr/
│       ├── 01_pwt.R
│       ├── 02_sipri.R
│       └── 03_midb.R
│
├── 02_prepare_data/
│
├── 03_regressions/
│   ├── output/
│   │   ├── 01_tabla_reg_principal.tex
│   │   └── 02_tabla_reg_mecanismo.tex
│   └── scr/
│       ├── 01_main_reg.R
│       └── 02_main_mecanismo.R
│
├── 04_descriptive/
│   ├── output/
│   │   └── 01_share_gdp_vs_conflict.png
│   └── scr/
│       └── 01_share_gdp_vs_conflict.R
│
├── 00_packages.R
├── RUNME.R
└── README.md
```