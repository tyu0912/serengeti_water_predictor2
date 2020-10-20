def get_test_probability(latitude, longitude, location_name, request_date):

    probability = 0
    label = 0

    if (latitude == "-2.302313" and longitude == "34.830778") or location_name == "Orangi River":
        probability = 0.1054820
        label = 1

    elif (latitude == "-1.562928" and longitude == "34.997068") or location_name == "Mara River":
        probability = 0.485481
        label = 0

    elif (latitude == "-1.595733" and longitude == "35.069241") or location_name == "Sand River":
        probability = 0.574513
        label = 0

    elif (latitude == "-2.249034" and longitude == "34.486842") or location_name == "Grumeti River":
        probability = 0.979454
        label = 0

    elif (latitude == "-3.024818" and longitude == "35.038474") or location_name == "Lake Masek":
        probability = 0.155415
        label = 1

    elif (latitude == "-3.202214" and longitude == "35.536431") or location_name == "Lake Magadi":
        probability = 0.548123
        label = 1

    elif (latitude == "-2.915433" and longitude == "35.841355") or location_name == "Lake Empakaai":
        probability = 0.884111
        label = 1

    elif (latitude == "-2.656248" and longitude == "34.788239") or location_name == "Lake Magadi":
        probability = 0.364100
        label = 0

    elif (latitude == "-2.603015" and longitude == "34.720511") or location_name == "Mbalageti River":
        probability = 0.487948
        label = 1

    elif (latitude == "-2.044819" and longitude == "34.230374") or location_name == "Ruwana River":
        probability = 0.126364
        label = 0

    elif (latitude == "-1.416096" and longitude == "35.097661") or location_name == "Talek River":
        probability = 0.122678
        label = 1

    else:
        probability = -1
        label = -1

    return probability, label
