function calc(numA, numB) {
    return numA + numB;
}

function openmenu() {

    httpGet("http://google.by");
}


function httpGet(theUrl) {

    $.ajax({
        type: "GET",
        url: "http://localhost:80/!hello",
        /*async: true,
        crossDomain: true,*/
        success: function (text) {
            alert(text);
        },
        error: function (request, error) {
            alert("Can't do because: " + error);
        }
    });
}

$(function () {

    var nodeAttr = [20, 1, 1, 1, 1, 1];

    var innerRadius = 120;
    var outerRadius = 30;
    var width = document.getElementById('content').clientWidth;
    var height = document.getElementById('content').clientHeight;

    var color = d3.scale.category20();

    var pie = d3.layout.pie()
                   .sort(null);

    var arc = d3.svg.arc()
                .innerRadius(innerRadius)
                .outerRadius(outerRadius);


    var svg = d3.select("#content").append("svg")
                           .attr("width", width)
                           .attr("height", height)
                           .append("g")
                           .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    var nodeGroup = svg.selectAll("g")
                .data(nodeAttr)
                .enter()
                .append("g");

    var path = nodeGroup.selectAll("path").data(pie(nodeAttr))
                           .enter()
                           .append("path")
                           .attr("fill", "white")
                           .attr("d", arc)
                           .each(function (d) { this._current = d; }); // store the initial values

    $(svg).bind("monitor", worker);
    $(svg).trigger("monitor");
    setInterval(worker, 500);

    function worker() {
        nodeAttr[0] += 1;
        var newRadius = nodeAttr[0];

        setAttr();
        path = path.data(pie(nodeAttr))
               .attr("fill", function (d, i) { return color(i) });

        path.transition().duration(500).attrTween("d", function (a) {
            var i = d3.interpolate(this._current, a),
             k = d3.interpolate(arc.outerRadius()(), newRadius);
            this._current = i(0);
            return function (t) {
                return arc.innerRadius(k(t) / 4).outerRadius(k(t))(i(t));
            };
        });

    }

    function setAttr() {
        for (var i = 1; i < nodeAttr.length; i++) {
            nodeAttr[i] = Math.floor(Math.random() * 10) + 1;
        }
    }

});