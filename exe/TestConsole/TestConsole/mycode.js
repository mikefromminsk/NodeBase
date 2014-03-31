var metaNodes = [];

$(function () {

    

    
    loadNode("@1");

    setMode();
});


function openmenu() {
    alert(metaNodes.length);
}

function indexOf(id) {
    for (var i = 0; i < metaNodes.length; i++) {
        if ((metaNodes[i].query == id) | (metaNodes[i].id == id)) {
            return metaNodes[i];
        }
    }
}

function loadNode(query) {
    var host = "http://localhost:82/";
    $.ajax({
        type: "GET",
        url: host + query,
        success: function (get) {

            var nodesArr = get.split('\n\n');
            var expr = /^((.*?)\^)?(.*?)?(@(.*?))(\$(.*?))?(\?(.*?))?(#(.*?))?(\|(.*?))?(\n(.*?))?$/g;
            var groups = expr.exec(nodesArr[0]);
            if (groups == null)
                return;
            nodesArr.shift();

            var focusNode = indexOf(groups[4]);

            if (!!!focusNode) {
                //create
                metaNodes.push({
                    query: "",
                    parent: groups[2],
                    name: groups[3],
                    id: groups[4],
                    sysparams: groups[7],
                    params: groups[9],
                    value: groups[11],
                    felse: groups[13],
                    next: groups[15],
                    local: nodesArr
                });
                focusNode = metaNodes[metaNodes.length - 1];
            }
            else {
                //update
                focusNode.query = "";
                focusNode.parent = groups[2];
                focusNode.name = groups[3];
                focusNode.id = groups[4];
                focusNode.sysparams = groups[7];
                focusNode.params = groups[9];
                focusNode.value = groups[11];
                focusNode.felse = groups[13];
                focusNode.next = groups[15];
                focusNode.local = nodesArr;
            }


            for (var i = 0; i < nodesArr.length; i++) {
                metaNodes.push({
                    query: nodesArr[i],
                    cx: !!!focusNode.cx ? 50 : focusNode.cx + 50,
                    cy: !!!focusNode.cy ? (i * 50) + 50 : focusNode.cy + (i * 50) + 50
                });
                loadNode(nodesArr[i]);
            }

        },
        error: function (request, error) {
            loadNode(query);
        }
    });
    
}


var mode = 3;


function setMode() {


    if (mode == 1) {

        var viewAttr = [20, 3, 5, 12];

        var innerRadius = 30;
        var outerRadius = 50;
        var width = document.getElementById('content').clientWidth,
            height = document.getElementById('content').clientHeight,
            margin = { top: -5, right: height / 2, bottom: -5, left: width / 2 };


        var color = d3.scale.category20();

        var pie = d3.layout.pie()
                .sort(null);

        var arc = d3.svg.arc()
                .innerRadius(innerRadius)
                .outerRadius(outerRadius);


                
        var zoom = d3.behavior.zoom()
            .scaleExtent([1, 10])
            .on("zoom", zoomed);
           
        var drag = d3.behavior.drag()
            .origin(function (d) { return d; })
            .on("dragstart", dragstarted)
            .on("drag", dragged)
            .on("dragend", dragended);
            
        function zoomed() {
            container.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }

        function dragstarted(d) {
            d3.event.sourceEvent.stopPropagation();
            d3.select(this).classed("dragging", true);
        }

        function dragged(d) {
            d3.select(this).attr("cx", d.x = d3.event.x).attr("cy", d.y = d3.event.y);
        }

        function dragended(d) {
            d3.select(this).classed("dragging", false);
        }

        


        var svg = d3.select("#content").append("svg")
                    .attr("width", width)
                    .attr("height", height)
                    .append("g")
                    .attr("transform", "translate(" + margin.left + "," + margin.right + ")")
                    .call(zoom);




        setInterval(update, 500);

        function update() {

            //create
            var nodeGroup = svg.selectAll("g")
                .data(metaNodes)
                .enter()
                .append("g")
                .attr("transform", function (d) { return "translate(" + d.cx + "," + d.cy + ")"; })
                .on('click', function (d) { alert(d.query); });

            var path = nodeGroup.selectAll("path")
                .data(pie(viewAttr))
                .enter()
                .append("path")
                .attr("fill", function (d, i) { return color(i) })
                .attr("d", arc)
                .each(function (d) { this._current = d; });

            /*var label = nodeGroup.append("text")
               .text(function (d) { return d.name; });*/


            //udpate

            var newRadius = viewAttr[0];

            for (var i = 1; i < viewAttr.length; i++) {
                viewAttr[i] = Math.floor(Math.random() * 10) + 1;

            svg.selectAll("g")
                    .attr("opacity", function (d) { return d.query == "" ? "1" : "0.3"; })
                    .selectAll("path")
                    .data(pie(viewAttr))
                    .transition()
                    .duration(500)
                    .attrTween("d", function (a) {
                var i = d3.interpolate(this._current, a),
                k = d3.interpolate(arc.outerRadius()(), newRadius);
                this._current = i(0);
                return function (t) {
                    return arc.innerRadius(k(t) / 4).outerRadius(k(t))(i(t));
                };
            });
        }

        
        }
    }






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




    if (mode == 3) {

        var margin = { top: -5, right: -5, bottom: -5, left: -5 },
            width = 960 - margin.left - margin.right,
            height = 500 - margin.top - margin.bottom;

        var zoom = d3.behavior.zoom()
            .scaleExtent([1, 10])
            .on("zoom", zoomed);

        var drag = d3.behavior.drag()
            .origin(function (d) { return d; })
            .on("dragstart", dragstarted)
            .on("drag", dragged)
            .on("dragend", dragended);

        var svg = d3.select("#content").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.right + ")")
            .call(zoom);

        var rect = svg.append("rect")
            .attr("width", width)
            .attr("height", height)
            .style("fill", "none")
            .style("pointer-events", "all");

        var container = svg.append("g");

        container.append("g")
            .attr("class", "x axis")
          .selectAll("line")
            .data(d3.range(0, width, 10))
          .enter().append("line")
            .attr("x1", function (d) { return d; })
            .attr("y1", 0)
            .attr("x2", function (d) { return d; })
            .attr("y2", height);

        container.append("g")
            .attr("class", "y axis")
          .selectAll("line")
            .data(d3.range(0, height, 10))
          .enter().append("line")
            .attr("x1", 0)
            .attr("y1", function (d) { return d; })
            .attr("x2", width)
            .attr("y2", function (d) { return d; });

   

       /* function dottype(d) {
            d.x = +d.x;
            d.y = +d.y;
            return d;
        }*/

        function zoomed() {
            container.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }

        function dragstarted(d) {
            d3.event.sourceEvent.stopPropagation();
            d3.select(this).classed("dragging", true);
        }

        function dragged(d) {
            d3.select(this).attr("cx", d.x = d3.event.x).attr("cy", d.y = d3.event.y);
        }

        function dragended(d) {
            d3.select(this).classed("dragging", false);
        }
    }






    
}



