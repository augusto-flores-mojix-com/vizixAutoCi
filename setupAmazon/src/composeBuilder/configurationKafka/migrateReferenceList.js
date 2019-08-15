var INPUT_FQN_REFLIST='/RED/REFERENCELIST';
var INPUT_FQN_CONTENT='/RED/CONTENT';
var TARGET_COLLECTION='referencelistcube';

db.createCollection(TARGET_COLLECTION);
db.getCollection(TARGET_COLLECTION).createIndex({'referenceListId':1});
db.getCollection(TARGET_COLLECTION).createIndex({'bizStep':1,'transactionId':1});
db.getCollection(TARGET_COLLECTION).createIndex({'creationTime':1});
db.getCollection(TARGET_COLLECTION).createIndex({'bizStepTransactionId':-1}, {"unique" : true} );

function mapper() {
    var referenceList = null;
    var content = [];
    var containers = [];
    if (this.referenceList && this.referenceList.value) {
        //content mode
        referenceList = this.referenceList.value;
        var containerId = (
            ( this.containerId && this.containerId.value )
            ?
            this.containerId.value.toFixed(0)
            :
            null
        );
        var sscc = (
            ( this.sscc && this.sscc.value )
            ?
            this.sscc.value
            :
            null
        );
        var contentObject = {
            "containerId" : containerId,
            "sscc" : sscc,
            "format" : (
                ( this.format && this.format.value )
                ?
                this.format.value
                :
                null
            ),
            "quantity" : (
                ( this.quantity && this.quantity.value )
                ?
                NumberLong( this.quantity.value )
                :
                null
            ),
            "gtin": (
                ( this.gtin && this.gtin.value )
                ?
                this.gtin.value
                :
                null
            ),
            "epc": (
                ( this.epc && this.epc.value )
                ?
                this.epc.value
                :
                null
            ),
            "hexa": (
                ( this.hexa && this.hexa.value )
                ?
                this.hexa.value
                :
                null
            ),
        };
        content.push( contentObject );
        containers.push(
            {
                "containerId" : containerId,
                "sscc" : sscc
            }
        );

    } else {
        //reference list mode
        referenceList = this;
    }
    if (! ( (referenceList != null) && referenceList.referenceListId && referenceList.referenceListId.value) ) {
        return;
    }
    var id = referenceList.referenceListId.value;
    var extensions = (
        ( referenceList.extension && referenceList.extension.value )
        ?
        JSON.parse(referenceList.extension.value)
        :
        {}
    );
    var bizStep = (
        ( referenceList.bizStep && referenceList.bizStep.value )
        ?
        referenceList.bizStep.value
        :
        null
    );
    var transactionId = (
        ( referenceList.transactionId && referenceList.transactionId.value )
        ?
        referenceList.transactionId.value
        :
        null
    );
    var bizStepTransactionId = (
        ( bizStep && transactionId )
        ?
        bizStep + "|" + transactionId
        :
        null
    );
    var doc = {
        "_id" : NumberLong(id),
        "referenceListId" : NumberLong(id),
        "contentFormat" : (
            ( referenceList.contentFormat && referenceList.contentFormat.value )
            ?
            referenceList.contentFormat.value
            :
            null
        ),
        "transactionId" : transactionId,
        "creationTime": (
            ( referenceList.creationTime && referenceList.creationTime.value )
            ?
            referenceList.creationTime.value.toISOString()
            :
            null
        ),
        "updateTime": (
            ( referenceList.modifiedTime )
            ?
            referenceList.modifiedTime.toISOString()
            :
            null
        ),
        "expirationTime": (
            ( referenceList.expirationTime && referenceList.expirationTime.value )
            ?
            referenceList.expirationTime.value.toISOString()
            :
            null
        ),
        "lastStatusChange": (
            ( referenceList.lastStatusChange && referenceList.lastStatusChange.value )
            ?
            referenceList.lastStatusChange.value.toISOString()
            :
            null
        ),
        "status" : (
            ( referenceList.status && referenceList.status.value )
            ?
            referenceList.status.value
            :
            null
        ),
        "bizStep" : bizStep,
        "bizLocation" : (
            ( referenceList.bizLocation && referenceList.bizLocation.value )
            ?
            referenceList.bizLocation.value
            :
            null
        ),
        "identifier" : referenceList["_id"],
        "extensions" : extensions,
        "bizStepTransactionId" : bizStepTransactionId,
        "content" : content,
        "containers" : containers

    }
    emit(id, doc)
}

function reducer(key, values) {
    var result = values[0];
    var containers = [];
    var content = [];
    var seenContainer = {};
    for (var i = 0; i < values.length; i++) {
        for (var j = 0; j < values[i].content.length; j++) {
            content.push( values[i].content[j] );
        }
        for (var r = 0; r < values[i].containers.length; r++) {
            var s = values[i].containers[r].containerId;
            if (s == null) {
                s = "null";
            }
            if ( typeof(seenContainer[s]) === 'undefined' ) {
                containers.push( values[i].containers[r] );
                seenContainer[s] = true;
            }
        }
    }
    result.content = content;
    result.containers = containers;
    result._id = key;
    return result;
}


db.getCollection( hex_md5(INPUT_FQN_REFLIST) + "_things").mapReduce(
    mapper,
    reducer,
    { out: TARGET_COLLECTION + "_temp" }
);
db.getCollection( hex_md5(INPUT_FQN_CONTENT) + "_things").mapReduce(
    mapper,
    reducer,
    { out: { reduce: TARGET_COLLECTION + "_temp" } }
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
