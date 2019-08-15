var INPUT_FQN='/RED/PRODUCT'
var TARGET_COLLECTION='productcube'

/*****************************************************************************
 *  Step 1:
 *  ------
 * Script to verify if there are duplicate products before migrating
 * (Retail_GTIN should be unique)
 * It should return an empty result. If there are duplicates, it will return
 * a list of serials with the issue.
 *
 ***************************************************************************/
db.getCollection( hex_md5(INPUT_FQN) + "_things").aggregate([
    {
        $match: {
            "Retail_GTIN.value": {$ne: null}
        }
    },
    {
        $group: {
            _id: "$Retail_GTIN.value",
            serialNumbers: {$push: "$serialNumber"}
        }
    },
    {
        $project: {_id: 1, serialNumbers: 1, time: 1, count: {$size: "$serialNumbers"}}
    },
    {
        $match: {
            count: {$gt: 1}
        }
    }
], {
    allowDiskUse: true
});



/*****************************************************************************
 *  Step 2:
 *  ------
 * Script to Migrate products
 *
 ***************************************************************************/
db.getCollection('productcube').createIndex({'productCode':'hashed'})
db.getCollection('productcube').createIndex({'modelCode':'hashed'})
db.getCollection('productcube').createIndex({'gtin':'hashed'})
db.getCollection('productcube').createIndex({'updateTimeMS':1})
db.getCollection( hex_md5(INPUT_FQN) + "_things").aggregate([
    {
        $match: {
            "serialNumber": { $regex : /^[^_].+$/ },
            "Retail_GTIN.value": { $ne : null }
        }
    },
    {
        $project: {
            "_id": "$Retail_GTIN.value",
            "gtin": "$Retail_GTIN.value",
            "time": {$literal: NumberLong(1)},
            "updateTime": {$dateToString: {date: "$time"}},
            "updateTimeMS": {$subtract: ["$time", new Date("1970-01-01")]},
            "extensions": "$Retail_Extension.value",
            "displayGtin": "$Retail_UPCNumber.value",
            "productCode": "$Retail_SKUOriginal.value",
            "productLabelShort": "$Retail_SubClassCode.value",
            "productLabelLong": "$Retail_SubClassName.value",
            "categoryParent": "$Retail_BusinessGroupName.value",
            "sizeCode": "$Retail_Size_Code.value",
            "sizeLabel": "$Retail_Size.value",
            "modelCode": "$Retail_Style_Code.value",
            "modelLabel": "$Retail_Style.value",
            "colorCode": "$Retail_Color_Code.value",
            "colorLabel": "$Retail_Color.value",
            "seasonCode": "$Retail_Season_Code.value",
            "seasonLabel": "$Retail_Season_Label.value",
            "madeinCode": "$Retail_Season_Madein_Code.value",
            "madeinLabel": "$Retail_Season_Madein_Label.value",
            "weightNet_value": "$Retail_Weight_Net_Value.value",
            "weightNet_unit": "$Retail_Weight_Net_Unit.value",
            "weightGross_value": "$Retail_Weight_Gross_Value.value",
            "weightGross_unit": "$Retail_Weight_Gross_Unit.value",
            "pictureDesktop": "$Retail_ImageURLDesktop.value",
            "pictureMobile": "$Retail_ImageURLMobile.value",
            "prices": "$Retail_Price.value",
            "identifier": "$_id",
            "brandCode": "$Retail_Brand_Code.value",
            "brandLabel": "$Retail_Brand.value",
            "bundleItemQuantity": {$toInt: "$Retail_Mate_Bundle.value"},
            "optionCode": "$Retail_Option_Code.value",
            "optionLabel": "$Retail_Option_Label.value",
            "vpn": "$Retail_VPN.value"
        }
    },
    {
        $out: TARGET_COLLECTION
    }
], {
    allowDiskUse: true
});