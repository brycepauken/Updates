var UPDHighlightCount = 0;

function UPDHighlightOccurrencesOfString(str) {
    UPDRemoveHighlights();
    UPDHighlightOccurrencesOfStringFromElement(str.toLowerCase(), document.body);
}

function UPDHighlightOccurrencesOfStringFromElement(str, element) {
    if(element) {
        if(element.nodeType==3) {
            while (true) {
                var content = element.nodeValue;
                var index = content.toLowerCase().indexOf(str);
                
                if(index<0) {
                    break;
                }
                
                var spanElement = document.createElement("span");
                var textElement = document.createTextNode(content.substr(index, str.length));
                spanElement.appendChild(textElement);
                
                spanElement.setAttribute("class","UPDHighlighted");
                spanElement.style.backgroundColor = "#f8f388";
                spanElement.style.color = "black";
                
                UPDHighlightCount++;
                
                textElement = document.createTextNode(content.substr(index+str.length));
                element.deleteData(index, content.length-index);
                var nextElement = element.nextSibling;
                element.parentNode.insertBefore(spanElement, nextElement);
                element.parentNode.insertBefore(textElement, nextElement);
                element = textElement;
            }
        }
        else if(element.nodeType==1) {
            if(element.style.display!="none"&&element.nodeName.toLowerCase()!="select") {
                for(var i=element.childNodes.length-1;i>=0;i--) {
                    UPDHighlightOccurrencesOfStringFromElement(str, element.childNodes[i]);
                }
            }
        }
    }
}

function UPDRemoveHighlights() {
    UPDHighlightCount = 0;
    UPDRemoveHighlightsFromElement(document.body);
}

function UPDRemoveHighlightsFromElement(element) {
    if(element && element.nodeType==1) {
        if(element.getAttribute("class") && element.getAttribute("class").indexOf("UPDHighlighted")>-1) {
            var content = element.removeChild(element.firstChild);
            element.parentNode.insertBefore(content,element);
            element.parentNode.removeChild(element);
            return true;
        }
        else {
            var shouldNormalize = false;
            for(var i=element.childNodes.length-1;i>=0;i--) {
                if(UPDRemoveHighlightsFromElement(element.childNodes[i])) {
                    shouldNormalize = true;
                }
            }
            if(shouldNormalize) {
                element.normalize();
            }
        }
    }
}