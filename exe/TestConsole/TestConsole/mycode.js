$(function () {

    setMode();
    var node = {
        query: "",
        id: "",
        name
    
    };


});


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


function nodesToJson() {

}


var mode = 1;


function setMode() {

    if (mode == 2) {



        var treeData = { 
            "name": "A",    
            "children": [
                        { "name": "A1" },
                        { "name": "A2" },
                        { 
                            "name": "A3",   
                            "children": [{ 
                                    "name": "A31", 
                                    "children": [
                                        { "name": "A311" },
                                        { "name": "A312" }
                                    ]
                             }]
                        }]
        };

        // Create a svg canvas
        var vis = d3.select("#content").append("svg:svg")
                .attr("width", 400)
                .attr("height", 300)
                .append("g")
                .attr("transform", "translate(40, 0)"); // shift everything to the right

        // Create a tree "canvas"
        var tree = d3.layout.tree()
                .size([300, 150]);

        var diagonal = d3.svg.diagonal()
                // change x and y (for the left to right tree)
                .projection(function (d) { return [d.y, d.x]; });

        // Preparing the data for the tree layout, convert data into an array of nodes
        var nodes = tree.nodes(treeData);
        // Create an array with all the links
        var links = tree.links(nodes);

        var link = vis.selectAll("pathlink")
                .data(links)
                .enter().append("path")
                /*.attr("class", "link")*/
                .attr("d", diagonal)
                .attr("fill", "none")
                .attr("stroke", "#ccc")
                .attr("stroke-width", 3);

        var node = vis.selectAll("node")
                .data(nodes)
                .enter().append("g")
                .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; })

        // Add the dot at every node
        node.append("circle")
                .attr("r", 3.5);

        // place the name atribute left or right depending if children
        node.append("text")
                .attr("dx", function (d) { return d.children ? -8 : 8; })
                .attr("dy", 3)
                .attr("text-anchor", function (d) { return d.children ? "end" : "start"; })
                .text(function (d) { return d.name; })
    }











    if (mode == 1) {
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
                .append("g")
                .attr("transform", function (d, i) { return "translate(" + 100 * i + ",0)"; });

        var path = nodeGroup.selectAll("path").data(pie(nodeAttr))
                .enter()
                .append("path")
                .attr("fill", function (d, i) { return color(i) })
                .attr("d", arc)
                .each(function (d) { this._current = d; }); // store the initial values

        /*$(svg).bind("monitor", worker);
        $(svg).trigger("monitor");*/
        setInterval(worker, 500);

        function worker() {
            nodeAttr[0] += 1;
            var newRadius = nodeAttr[0];


            setAttr();

            path.data(pie(nodeAttr)).transition().duration(500).attrTween("d", function (a) {
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
    }
}



