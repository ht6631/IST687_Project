# Here's a code draft where you can run and test ur code.


library(stats)
house_factor <- static_house %>%
  mutate_if(sapply(static_house, is.character), as.factor)
house_num=house_factor%>%mutate_if(sapply(house_factor,is.factor),as.numeric)
house_num_scaled=scale(house_num)



redundant_col=c('in.geometry_stories_low_rise','in.misc_pool','in.hvac_has_ducts',
                'in.plug_load_diversity','in.water_heater_fuel','in.vintage_acs',
                'in.hvac_heating_type_and_fuel','upgrade.cooking_range','in.geometry_attic_type',
                'upgrade.insulation_foundation_wall','in.hvac_cooling_type','upgrade.geometry_foundation_type',
                'in.heating_fuel','upgrade.clothes_dryer','in.cooling_setpoint_has_offset','upgrade.water_heater_efficiency',
                'in.geometry_floor_area_bin')
static_house_new=static_house[,!colnames(static_house) %in% redundant_col]





# wss=0
# listt=c(50:100)
# for (i in listt){
#   km.out=kmeans(house_num[2:98],centers=i,nstart = 20)
#   wss[i]=km.out$tot.withinss
# }
# plot(listt,wss[listt],type='b',
#      xlab='Number of Clusters',
#      ylab='Within groups sum of squares')
# 
# k=100
# km_house=kmeans(house_num,centers=k,nstart=20)
# plot(house_num[,c('in.sqft','in.income')],col=km_house$cluster)









# To avoid R no reponse, I added [1] at the beginning of for loop, remove it for all data
# for the energy usage data of each building, here's the process of getting eu data
for (item in static_house_cleaned$bldg_id[1]){
  # 1st. Building ID
  bldg_id=as.character(item)
  # 2nd. Retrieve from cloud
  temp_energy_usage=read_parquet(paste('https://intro-datascience.s3.us-east-2.amazonaws.com/SC-data/2023-houseData/',bldg_id,'.parquet',sep=''))
  # 3rd. Extract info for just July
  temp_energy_usage$bldg_id=as.numeric(bldg_id)
  temp_energy_usage=temp_energy_usage%>%filter(month(time)==7)
  temp_energy_usage=temp_energy_usage[,c(44,43,1:42)]
  if (bldg_id=='65'){
    energy_usage=temp_energy_usage
  }else{energy_usage=rbind(energy_usage,temp_energy_usage)}
  # Remove temp data
  rm(temp_energy_usage,item,bldg_id)
}


# To avoid R no reponse, I added [1] at the beginning of for loop, remove it for all data
# for each county, here's the process of getting weather data
for (item in unique(static_house_cleaned$county)[1]){
  # 1st. County ID
  county_id=item
  # 2nd. Retrieve from cloud
  temp_weather=read_csv(paste('https://intro-datascience.s3.us-east-2.amazonaws.com/SC-data/weather/2023-weather-data/',county_id,'.csv',sep=''))
  # 3rd. Extract info for just July
  temp_weather=temp_weather%>%filter(month(date_time)==7)
  # 4th. Add county id
  temp_weather=temp_weather%>%rename(time=date_time)
  temp_weather$county=county_id
  temp_weather=temp_weather[,c(1,9,2:8)]
  if (county_id=='G4500910'){
    weather=temp_weather
  }else{weather=rbind(weather,temp_weather)}
  rm(temp_weather,item,county_id)
}

energy_usage$total=rowSums(energy_usage[3:44])
energy_res=energy_usage[,c(1,2,45)]

temp_house=static_house[1:5,]
temp_house=left_join(temp_house,energy_res,by='bldg_id')
temp_house=left_join(temp_house,weather,by=c('county','time'))
temp_house=temp_house%>%mutate_if(sapply(temp_house,is.character),as.factor)
temp_house=temp_house%>%mutate_if(length(unique(temp_house))==1,as.character)
temp_house=temp_house %>% select(where(~n_distinct(.) > 1))
lm_house=lm(total~.,data=temp_house[,-c(1,2,79)])
summary(lm_house)



for (i in c(1:nrow(static_house_cleaned))){
  bldg_id=as.character(static_house_cleaned$bldg_id[i])
  county=as.character(static_house_cleaned$county[i])
  temp_energy_usage=read_parquet(paste('https://intro-datascience.s3.us-east-2.amazonaws.com/SC-data/2023-houseData/',bldg_id,'.parquet',sep=''))
  temp_energy_usage$bldg_id=as.numeric(bldg_id)
  temp_energy_usage=temp_energy_usage%>%filter(month(time)==7)
  temp_energy_usage=temp_energy_usage[,c(44,43,1:42)]
  temp_weather=read_csv(paste('https://intro-datascience.s3.us-east-2.amazonaws.com/SC-data/weather/2023-weather-data/',county,'.csv',sep=''))
  temp_weather=temp_weather%>%filter(month(date_time)==7)
  temp_weather=temp_weather%>%rename(time=date_time)
  temp_weather$county=county
  temp_weather=temp_weather[,c(1,9,2:8)]
  temp_1house=left_join(temp_energy_usage,temp_weather,by='time')
  temp_1house=left_join(temp_1house,static_house_cleaned[i,],by=c('bldg_id','county'))
}
county




load('ProjectData.RData')
model_table$time=as.POSIXct(model_table$time,tz=tz)
time_list=unique(model_table$time)[741:744]
remake_table=model_table%>%filter(time %in% time_list)
done_table=model_table%>%filter(!time %in% time_list)
remake_table=remake_table[,1:45]
check_table=static_house_cleaned[,c('bldg_id','county')]
remake_table=left_join(remake_table,check_table,by='bldg_id')
for (i in c(1:46)){
  county=as.character(unique(static_house_cleaned$county)[i])
  temp_weather=read_csv(paste('https://intro-datascience.s3.us-east-2.amazonaws.com/SC-data/weather/2023-weather-data/',county,'.csv',sep=''),show_col_types = FALSE)
  temp_weather$date_time=as.POSIXct(temp_weather$date_time,tz=tz)
  temp_weather=temp_weather%>%filter(month(date_time)==7)
  temp_weather=temp_weather%>%rename(time=date_time)
  temp_weather$county=county
  temp_weather=temp_weather[741:744,c(1,9,2:8)]
  if (i==1){
    weather=temp_weather
  }else{weather=rbind(weather,temp_weather)}
}
temp_table=left_join(remake_table,weather,by=c('time','county'))
temp_table=left_join(temp_table,static_house_cleaned,by=c('bldg_id','county'))
temp_done_table=done_table %>%
  mutate_if(sapply(done_table, is.factor), as.character)
glimpse(temp_done_table)
model_table=rbind(temp_table,temp_done_table)
model_table=model_table%>%arrange(bldg_id,time)
na_count <-sapply(model_table, function(y) sum(length(which(is.na(y)))))%>%as.data.frame()
model_table=model_table %>%
  mutate_if(sapply(model_table, is.character), as.factor)
glimpse(model_table)

unique(static_house_cleaned$in.cooling_setpoint)
temp_house=static_house_cleaned %>% slice(rep(1:n(), each = 744))
model_table$in.cooling_setpoint=temp_house$in.cooling_setpoint
model_table$in.heating_setpoint=temp_house$in.heating_setpoint
model_table$upgrade.insulation_roof=temp_house$upgrade.insulation_roof
model_table$upgrade.infiltration_reduction=temp_house$upgrade.infiltration_reduction
model_table$upgrade.insulation_ceiling=temp_house$upgrade.insulation_ceiling
model_table$upgrade.ducts=temp_house$upgrade.ducts
model_table$upgrade.hvac_heating_type=temp_house$upgrade.hvac_heating_type
model_table$upgrade.insulation_wall=temp_house$upgrade.insulation_wall
model_table=model_table %>%
  mutate_if(sapply(model_table, is.character), as.factor)

rm(check_table,done_table,na_count,remake_table,temp_done_table,temp_energy_usage,temp_house,
   temp_table,temp_weather,weather)
rm(bldg_id,county,i,time_list,tz)











