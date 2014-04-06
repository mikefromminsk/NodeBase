var metaNodes = [];

$(function () {

    loadNode("@1");

    setMode();
});


function openmenu() {
    alert(metaNodes.length);
}

function getNode(id) {
    if (!!!id) return;
    for (var i = 0; i < metaNodes.length; i++) {
        if ((metaNodes[i].query == id) | (metaNodes[i].id == id)) {
            return metaNodes[i];
        }
    }
}

function loadNode(query, n) {
    if (!!n == false)
        n = 1;
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


            var paramsArr = !!groups[9] ? groups[9].split('&') : [];

            var focusNode = getNode(groups[4]);

            if (!!!focusNode) {
                //create
                metaNodes.push({
                    query: "",
                    source: groups[2],
                    name: groups[3],
                    id: groups[4],
                    sysparams: groups[7],
                    params: paramsArr,
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
                focusNode.source = groups[2];
                focusNode.name = groups[3];
                focusNode.id = groups[4];
                focusNode.sysparams = groups[7];
                focusNode.params = paramsArr;
                focusNode.value = groups[11];
                focusNode.felse = groups[13];
                focusNode.next = groups[15];
                focusNode.local = nodesArr;
            }
        },
        error: function (request, error) {
            if (n < 3)
                loadgetNode(query, n + 1);
        }
    });

}




function loadLinks(node) {


    var height = !!node.height ? node.height : 0;

    if (node.query == "")

    if (!!node.local)//and expand true
        for (var i = 0; i < node.local.length; i++) {
            metaNodes.push({query: node.local[i], color: "red", parentLocal: node.id});
            loadNode(node.local[i]);
        }

    if (!!node.next) {
        metaNodes.push({query: node.next, color: "green", prev: node.id });
        loadNode(node.next);
    }
    setPosition(node);
}


var r = 40;
var distance = 10;
var right = r;
var down = r + distance;

function setPosition(root) {
    if (!!!root) return;

    var x = !!root.x ? root.x : 0,
        y = !!root.y ? root.y : 0,
        height = 0;

    if (!!root.local) {
        
        for (var i = 0; i < root.local.length; i++) {
            var node = getNode(root.local[i]);
            node.y = y + down + (i * down) + !!node.height ? node.height : 0;
            node.x = x + right;

            height += down;
        }
        
    }
    
    /*
    var next = root.next,
        next_count = 0;

    for (; ; ) {
        if (!!!next)
            break;
        var node = getNode(next);
        
        node.y = y + height + (next_count * down);
        node.x = x;

        height += down;

        next_count += 1;
        next = node.next;
    }
    


    
    setPosition(getNode(root.prev));*/

    root.height = height;
    setPosition(getNode(root.parentLocal));
}

var mode = 1;


function setMode() {


    if (mode == 1) {

        var viewAttr = [20, 3, 5, 12];


        var startInnerRadius = 12;
        var startOuterRadius = 20;
        var margin = { top: 0, right: 0, bottom: 0, left: 0 },
            width = document.getElementById('content').clientWidth,
            height = document.getElementById('content').clientHeight;


        var color = d3.scale.category20();

        var pie = d3.layout.pie()
                .sort(null);

        var arc = d3.svg.arc()
                .innerRadius(startInnerRadius)
                .outerRadius(startOuterRadius);
                
        var zoom = d3.behavior.zoom()
            .scaleExtent([1, 10])
            .on("zoom", zoomed)
            ;
           
        var drag = d3.behavior.drag()
            .origin(function (d) { return d; })
            .on("dragstart", dragstarted)
            .on("drag", dragged)
            .on("dragend", dragended);

        var svg = d3.select("#content").append("svg")
            .attr("width", width)
            .attr("height", height)
            .on("dblclick.zoom", null)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.right + ")")
            .call(zoom)
            .on("dblclick.zoom", null)
            ;
                   
        var rect = svg.append("rect")
            .attr("width", width)
            .attr("height", height)
            .style("fill", "none")
            .style("pointer-events", "all");

        svg = svg.append("g");

        function zoomed() {
            svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }

        function dragstarted(d) {
            d3.event.sourceEvent.stopPropagation();
            //d3.select(this).classed("dragging", true);
        }
        
        function dragged(d) {
            d3.select(this).attr("transform", function (d) { return "translate(" + (d.x = d3.event.x) + "," +  (d.y = d3.event.y) + ")"; });//
            document.getElementById("footer").innerHTML = d.x;
        }

        function dragended(d) {
            //d3.select(this).classed("dragging", false);
        }
        

        setInterval(update, 500);

        function update() {
        

            var g = svg.selectAll("g")
                .data(metaNodes);

            //create
            var nodeGroup = g
                .enter()
                .append("g")
                .call(drag);
                
            g.attr("transform", function (d) { return "translate(" + d.x + "," + d.y + ")"; });

            var path = nodeGroup.selectAll("path")
                .data(pie(viewAttr))
                .enter()
                .append("path")
                .attr("fill", function (d, i) { return color(i) })
                .attr("d", arc)
                .each(function (d) { this._current = d; });

            var circle = nodeGroup
                .append("circle")
                .attr("r", 20)
                .attr("fill", function (d) { return d.color; })
                .attr("opacity", 0.5)
                .on("dblclick", function (d) {

                    d.expand = !!d.expand ? !d.expand : true;    
                    loadLinks(d);
      
                });
                ;

            /*var label = nodeGroup.append("text")
               .text(function (d) { return JSON.stringify(d.params); });*/


            //udpate

            var newRadius = viewAttr[0];

            /*for (var i = 1; i < viewAttr.length; i++) 
                viewAttr[i] = Math.floor(Math.random() * 10) + 1;*/

            svg.selectAll("g")
                    .attr("opacity", function (d) { return d.query == "" ? "1" : "0.3"; })
                    .selectAll("path")
                    .data(pie(viewAttr))
                    /*.transition()
                    .duration(500)
                    .attrTween("d", function (a) {
                var i = d3.interpolate(this._current, a),
                k = d3.interpolate(arc.outerRadius()(), newRadius);
                this._current = i(0);
                return function (t) {
                    return arc.innerRadius(k(t) / 4).outerRadius(k(t))(i(t));
                };
            })*/;
        }
    }



    
}



