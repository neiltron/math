var Sidebar = {

  bindEvents: function () {
    this.bindHotkeys();

    //when entry form is active, use item list as
    // an autofiller for the Amount input
    var items = $('#items');
    items.find('a').bind('click', function (e) {
      if (items.hasClass('active')) {
        e.preventDefault();

        $('#item_name').val($(e.target).text());
        $('#amount').focus();
      }
    });

    $('#plus').bind('mousedown touchstart', Sidebar.toggle );

    $('#board_form').bind('submit', Sidebar.createNewBoard );

  },

  show: function () {
    $('body').addClass('sidebar');
  },

  hide: function () {
    $('body').removeClass('sidebar');
  },

  toggle: function (e) {
    e.preventDefault();

    if (!$('body').hasClass('sidebar')) {
      Sidebar.show();
    } else {
      Sidebar.hide();
    }
  },

  bindHotkeys: function () {
    key.filter = function (event) {
      var tagName = (event.target || event.srcElement).tagName;
      return !(tagName == 'SELECT' || tagName == 'TEXTAREA');
    };

    key('=', function(e){
      e.preventDefault();

      Sidebar.show();
    });

    //switch to records list with escape
    key('esc', function(e){
      e.preventDefault();

      Sidebar.hide();
    });
  },

  createNewBoard: function (e) {
    e.preventDefault();

    if ($('#board_form #name').val() === '') {
      return false;
    }

    $.ajax({
      type: 'post',
      url: '/api/1/users/' + user_id + '/categories',
      dataType: 'json',
      data: {
        accesskey:  accesskey,
        name:  $('#board_form #board_name').val(),
      },
      success: function (data) {
        $('#board_name').val('');
        $('#boards').prepend('<li><a href="/categories/' + data.id + '">' + data.name + '</a></li>');

        if ($('#boards li').length >= 10) {
          $('#boards li').last().remove();
        }
      }
    });
  }

};