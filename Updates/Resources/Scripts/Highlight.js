var UPDHighlightCount = 0;

function UPDHighlightOccurrencesOfString(str) {
    UPDRemoveHighlights();
    str = str.toLowerCase();
    if(str && !(/^\s*$/.test(str))) {
        var elements = document.getElementsByTagName("*");
        for(var i=0; i<elements.length; i++) {
            var element = elements[i];
            if(element.hasChildNodes() && element.childNodes[0].nodeType==3) {
                element = element.childNodes[0];
                var content = element.nodeValue;
                var index = content.toLowerCase().indexOf(str);
                if(index<0) {
                    continue;
                }
                
                var spanElement = document.createElement("span");
                var textElement = document.createTextNode(content.substr(index, str.length));
                spanElement.appendChild(textElement);
                
                spanElement.setAttribute("class","UPDHighlighted");
                spanElement.style.backgroundColor = "#f8f388";
                spanElement.style.color = "black";
                spanElement.style.fontSize = "inherit";
                
                UPDHighlightCount++;
                
                textElement = document.createTextNode(content.substr(index+str.length));
                element.deleteData(index, content.length-index);
                var nextElement = element.nextSibling;
                element.parentNode.insertBefore(spanElement, nextElement);
                element.parentNode.insertBefore(textElement, nextElement);
                element = textElement;
                
                i++;
            }
        }
    }
}

function UPDRemoveHighlights() {
    UPDHighlightCount = 0;
    var elements = document.getElementsByTagName("*");
    for(var i=0; i<elements.length; i++) {
        var element = elements[i];
        if(element.getAttribute("class") && element.getAttribute("class")=="UPDHighlighted") {
            var content = element.removeChild(element.firstChild);
            var parent = element.parentNode;
            parent.insertBefore(content,element);
            parent.removeChild(element);
            parent.normalize();
        }
    }
}