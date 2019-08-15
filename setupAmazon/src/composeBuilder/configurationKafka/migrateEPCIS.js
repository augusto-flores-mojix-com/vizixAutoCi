var INPUT_FQN='/RED/EPCISEVENT';
var TARGET_COLLECTION='epciseventcube';

db.createCollection(TARGET_COLLECTION);
db.getCollection(TARGET_COLLECTION).createIndex({'eventTime':-1})
db.getCollection(TARGET_COLLECTION).createIndex({'bizTransList.value':1, "bizStep":1})
db.getCollection(TARGET_COLLECTION).createIndex({'bizStepTransactionId':1})

function mapper() {
    if ( !(this.value.Retail_EPC_PureIdentity) && !(this.value.Retail_EPC_PureIdentity.value) ) {
        return;
    }
    if ( !(this.value.Retail_EventId) && !(this.value.Retail_EventId.value) ) {
        return;
    }
    var COPY_FIELDS = [
        ["bizLocation"        , "Retail_Bizlocation_Original"],
        ["readPoint"          , "Retail_ReadPoint"],
        ["logicalReaderALE"   , "logicalReaderALE"],
        ["logicalReader"      , "logicalReader"],
        ["action"             , "Retail_Action"],
        ["id"            , "Retail_EventId"],
        ["type"         , "Retail_Object_Type"],
        ["premise"         , "Retail_Premise"],
    ];
    var id = this.value.Retail_EventId.value;
    var zoneLocalMap = null;
    var disposition = null;
    var bizStep = null;
    if ( (this.value.zm) && (this.value.zm.value) && (this.value.zm.value.group) ) {
        zoneLocalMap = { id: this.value.zm.value.group.name };
    }
    if ( (this.value.Retail_Disposition) && (this.value.Retail_Disposition.value)
     && (this.value.Retail_Disposition.value.Retail_URI) ) {
         disposition = this.value.Retail_Disposition.value.Retail_URI.value;
    }
    if ( (this.value.Retail_Bizstep) && (this.value.Retail_Bizstep.value)
     && (this.value.Retail_Bizstep.value.Retail_URI) ) {
         bizStep = this.value.Retail_Bizstep.value.Retail_URI.value;
    }


    var epcisEvent = {
        "_id" : id,
        "time" : this.time,
        "epcList": [ {
            "epc" : this.value.Retail_EPC_PureIdentity.value,
            "tid" : (this.value.Retail_UHF_Id ? this.value.Retail_UHF_Id.value : null),
            "uid" : (this.value.Retail_HF_Id ?  this.value.Retail_HF_Id.value  : null)
        } ],
        "bizTransList" : [ {
            "value" : (
                (this.value.Retail_BizTransactionId)
                ?
                this.value.Retail_BizTransactionId.value
                :
                null
            ),
            "type"  : (
                (this.value.Retail_BizTransactionType)
                ?
                this.value.Retail_BizTransactionType.value.serialNumber
                :
                null
            )
        } ],
        "disposition": disposition,
        "bizStep": bizStep,
        "firstSeenTime": NumberLong(this.value.createdTime.getTime()),
        "firstSeenTimeStr": this.value.createdTime.toISOString(),
        "recordTime": NumberLong(this.value.modifiedTime.getTime()),
        "recordTimeStr": this.value.modifiedTime.toISOString(),
        "eventTime": NumberLong(this.value.time.getTime()),
        "eventTimeStr": this.value.time.toISOString(),
        "extension" : (
            (this.value.Retail_Extension && this.value.Retail_Extension.value)
            ?
            JSON.parse(this.value.Retail_Extension.value)
            :
            {}
        ),
        "zoneLocalMap": zoneLocalMap,
    };
    for (var i=0; i < COPY_FIELDS.length; i++) {
        var f = COPY_FIELDS[i][1];
        var g = COPY_FIELDS[i][0];
        if( this.value[f] ) {
            epcisEvent[g] = this.value[f].value;
        } else {
            epcisEvent[g] = null;
        }
    }
    if (epcisEvent.bizStep && epcisEvent.bizTransList[0].value) {
        epcisEvent.bizStepTransactionId = epcisEvent.bizStep + "|" + epcisEvent.bizTransList[0].value;
    }
    emit(id, epcisEvent)
}

function reducer(key, values) {
    var result = values[0];
    var epcList = [];
    var bizTransList = [];
    for (var i = 0; i < values.length; i++) {
        var value = values[i];
        for (var j = 0; j < value.epcList.length; j++) {
            epcList.push( value.epcList[j] );
        }
        for (j = 0; j < value.bizTransList.length; j++) {
            if (    (bizTransList.length == 0)
                 || ( value.bizTransList[j].value != bizTransList[bizTransList.length -1].value )
            ) {
                bizTransList.push( value.bizTransList[j] );
            }
        }
        if (value.time > result.value) {
            result = value;
        }
    }
    result.epcList = epcList;
    result.bizTransList = bizTransList;
    result._id = result._id;
    return result;
}


db.getCollection( hex_md5(INPUT_FQN) + "_snapshots").mapReduce(
    mapper,
    reducer,
    { out: TARGET_COLLECTION + "_temp" }
);
db.getCollection( TARGET_COLLECTION + "_temp" ).aggregate([
    {
        $replaceRoot: { "newRoot" : "$value" }
    },
    {
        $out: TARGET_COLLECTION
    }
])
db.getCollection( TARGET_COLLECTION + "_temp" ).drop()