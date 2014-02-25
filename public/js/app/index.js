var items = [];
var records = {};
var chart;

window.addEventListener('load', function() {
  new FastClick(document.body);
}, false);

Sidebar.bindEvents();
EntryForm.bindEvents();
ItemTable.bindEvents();

$(document).ready(function ($) {
  isNumber = function (value) {
    if ((undefined === value) || (null === value)) {
      return false;
    }
    if (typeof value == 'number') {
      return true;
    }
    return !isNaN(value - 0);
  };

  drawGraphs();
});

function drawGraphs () {
  $('div.record_display').each(function (i, el) {
    var item_id = $(el).data('item-id');

    d3.json('/api/1/users/' + user_id + '/items/' + item_id + '/records.json?accesskey=' + accesskey, function(data) {
      nv.addGraph(function() {
        prepareLineGraph([return_values(data)], '#chart_' + item_id + ' svg');

        //append legend dots to the items table
        if (typeof category_id !== 'undefined') {
          $('table.records tbody tr').each(function(i, item) {
            $(item).find('td').first().prepend("<td><span style='height:10px;width:10px;display:block;float:left;border-radius:5px;margin:5px 5px 0 0;background:" + graph_data[i].color + "'></span></td>");
          });
        }

        return chart;
      });
    });
  });
}

function prepareLineGraph (data, selector) {
  chart = nv.models.lineChart()
            .width($('body').width() - 15)
            .tooltipContent(function (key, x, y, e, graph) {
              var tooltip = [];

              if (key !== '' && typeof key !== 'undefined') {
                tooltip.push('<p>' + key + '</p>');
              }

              tooltip.push('<p>' + y + ' at ' + x + '</p>');

              return tooltip;
            });

  chart.xAxis
    .tickFormat(function(d) {
      return d3.time.format('%_m/%d')(new Date(d * 1000));
    });

  chart.yAxis
    .tickFormat(d3.format());

  d3.select(selector)
        .datum(data)
        .transition().duration(500)
        .call(chart);

      //TODO: Figure out a good way to do this automatically
      nv.utils.windowResize(chart.update);
}

function return_values (data, i) {
    var key = data.key || '';

    var values = $(data.values).map(function(i, value) {
      if (isNumber(value[1])) {
        return { key: data.name, x: value[0], y: value[1] };
      }
    });

    var colors = [
      '#faa',
      '#f66',
      '#333',
      '#366',
      '#399',
      '#9cc'
    ];

    return {
      area: true,
      values: values,
      color: colors[i] || '#faa',
      key: key
    };
  }