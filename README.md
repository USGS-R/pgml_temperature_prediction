# pgml_temperature_prediction

### The different remake files

 -  `1_all_raw_data.yml`:  Pulls down the raw data files from google drive.  Depends on the `rawfile_to_id_crosswalk.csv`
 
 - `1_all_wqp`: Pulls down data for each NHD lake, based on an existing crosswalk of NHD sites to WQP sites.  Depends on the `master_lake.csv` file for the NHD lakes to check.
 
 - `1_data_s3_assimilate`: Munges all the files from `1_all_raw_data.yml` into a standard format, with four columns: DateTime, depth in meters, temp in Celsius, and a column named corresponding to a state ID system (i.e. DOW).  The last column will be used to regroup the data into seperate NHD files.  Each file requires it's own parsing function (named parse_<filename>), since there is no standard format.  The parsing function should change units if necessary, and add in ID if none is provided in the original file.  Depends on `rawfile_to_id_crosswalk.csv` for the list of files to parse, and also needs to rebuild if `1_all_raw_data changes`.
 
 - `2_get_model_files`: Sets of nml and driver files for GLM for each NHD lake.  Only depends on `master_lake.csv`.
 
 - `3_regroup_data`: Takes the munged files from `1_data_s3_assimilate` and regroups the data into files by NHD ID.  It also does some 'universal' cleaning, like checking for duplicates and filtering out data points beyond the maximum lake depth, and beyond the start, stop and max temp values set in the base model config file.  Depends on the `lake_master.csv` to relate state IDs to NHDs, and needs to rebuild if `1_data_s3_assimilate` changes.  It also depends on `2_get_model_files`, since the `clean_universal` function removes observations with depths below the maximum depth in the lake NML file.  
 