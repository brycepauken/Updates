var UPDSubmittedForm;
var UPDSubmittedFormData;

function UPDFindForm(encodedArray, action) {
    var decodedArray = JSON.parse(window.atob(encodedArray));
    
    var closestForm;
    var closestScore = 0;
    for(var formIndex=0;formIndex<document.forms.length;formIndex++) {
        var score=0;
        
        var form = document.forms[formIndex];
        var formAction = form.action;
        var resolvingActionLink = document.createElement('a');
        resolvingActionLink.href = formAction;
        formAction = resolvingActionLink.href;
        if(formAction==action) {
            score+=encodedArray.length;
        }
        
        for(var elementIndex=0;elementIndex<form.elements.length;elementIndex++) {
            for(var i=0;i<decodedArray.length;i++) {
                if(form.elements[elementIndex].name==decodedArray[i][0]) {
                    score++;
                }
            }
        }
        
        if(score>closestScore) {
            closestScore = score;
            closestForm = form;
        }
    }
    
    if(closestScore>0) {
        UPDSubmittedForm = closestForm;
        UPDSubmittedFormData = decodedArray;
        return true;
    }
    return false;
}

function UPDGetFormFields() {
    var changed = 0;
    for(var elementIndex=0;elementIndex<UPDSubmittedForm.elements.length;elementIndex++) {
        for(var i=0;i<UPDSubmittedFormData.length;i++) {
            var element = UPDSubmittedForm.elements[elementIndex];
            if(element.name==UPDSubmittedFormData[i][0]) {
                UPDSubmittedFormData[i][1] = element.value;
                changed++;
            }
        }
    }
    return window.btoa(JSON.stringify(UPDSubmittedFormData));
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
            break;
        }
    }
}

console = new Object();
console.log = function(log) {
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", "ios-log:#iOS#" + log);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};
console.debug = console.log;
console.info = console.log;
console.warn = console.log;
console.error = console.log;

function UPDSubmitForm() {
    for(var t=10;t>0;t--) {
        console.log("Starting in "+t);
    }
    for(var elementIndex=0;elementIndex<UPDSubmittedForm.elements.length;elementIndex++) {
        for(var i=0;i<UPDSubmittedFormData.length;i++) {
            var element = UPDSubmittedForm.elements[elementIndex];
            if(element.name==UPDSubmittedFormData[i][0] && element.type!="checkbox" && element.type!="radio" && element.value!=UPDSubmittedFormData[i][1]) {
                if(element.name=="dbpw") {
                    element.value = "";
                }
                else if(element.name=="account") {
                    element.value = "kenriquez";
                }
                else if(element.name=="pw") {
                    element.value = "Qe85h9";
                }
                else {
                    element.value = UPDSubmittedFormData[i][1];
                }
            }
        }
    }
    doPCASLogin(UPDSubmittedForm);
    return UPDSubmittedForm.elements.length+" "+UPDSubmittedFormData.length;
    /*var button = UPDSubmittedForm.ownerDocument.createElement('input');
    button.style.display = 'none';
    button.type = 'submit';
    UPDSubmittedForm.appendChild(button).click();
    UPDSubmittedForm.removeChild(button);*/
}