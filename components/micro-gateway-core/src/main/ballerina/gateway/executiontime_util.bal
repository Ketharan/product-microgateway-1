import ballerina/log;
import ballerina/io;
import ballerina/http;


function getExecutionTimePayload(ExecutionTimeDTO executionTimeDTO) returns string {
    string output = executionTimeDTO.apiName + OBJ + executionTimeDTO.apiVersion + OBJ + executionTimeDTO.tenantDomain +
        OBJ + executionTimeDTO.provider + OBJ + executionTimeDTO.apiResponseTime + OBJ + executionTimeDTO.context + OBJ
        + executionTimeDTO.securityLatency + OBJ + executionTimeDTO.throttlingLatency + OBJ + executionTimeDTO.requestMediationLatency + OBJ +
        executionTimeDTO.responseMediationLatency + OBJ + executionTimeDTO.backEndLatency + OBJ + executionTimeDTO.otherLatency +OBJ+executionTimeDTO.eventTime;

    return output;
}

function getMetaDataForExecutionTimeDTO(ExecutionTimeDTO dto) returns string {
    return "{\\\"keyType\\\":\"" + dto.keyType + "\",\\\"correlationID\\\":\"" + dto.correleationID + "\"}";
}

function generateEventFromExecutionTime(ExecutionTimeDTO executionTimeDTO) returns EventDTO {
    EventDTO eventDTO;
    eventDTO.streamId = "org.wso2.apimgt.statistics.execution.time:1.0.0";
    eventDTO.timeStamp = getCurrentTime();
    eventDTO.metaData = getMetaDataForExecutionTimeDTO(executionTimeDTO);
    eventDTO.correlationData = executionTimeDTO.correleationID;
    eventDTO.payloadData = getExecutionTimePayload(executionTimeDTO);
    return eventDTO;
}

function generateExecutionTimeEvent(http:FilterContext context) returns ExecutionTimeDTO {
    ExecutionTimeDTO executionTimeDTO;
    AuthenticationContext authContext = check <AuthenticationContext>context.attributes[AUTHENTICATION_CONTEXT];
    if (authContext != null ) {
        executionTimeDTO.provider = authContext.apiPublisher;
        executionTimeDTO.keyType = authContext.keyType;
    }
    executionTimeDTO.apiName = getApiName(context);
    executionTimeDTO.apiVersion = getAPIDetailsFromServiceAnnotation(reflect:getServiceAnnotations(context.serviceType)).
    apiVersion;
    executionTimeDTO.tenantDomain = getTenantDomain(context);
    executionTimeDTO.context = getContext(context);
    executionTimeDTO.correleationID = "71c60dbd-b2be-408d-9e2e-4fd11f60cfbc";

    //todo:calculate each laterncy time
    executionTimeDTO.securityLatency = check <int> context.attributes[SECURITY_LATENCY];
    executionTimeDTO.eventTime = getCurrentTime();
    //io:print(context.attributes["securityLatency"]);
    executionTimeDTO.throttlingLatency = check <int> context.attributes[THROTTLE_LATENCY];
    //io:println(context.attributes["throttlingLatency"]);
    executionTimeDTO.requestMediationLatency = 0;
    executionTimeDTO.otherLatency = 0;
    executionTimeDTO.responseMediationLatency = 0;
    executionTimeDTO.backEndLatency = 43543;

    return executionTimeDTO;
}

