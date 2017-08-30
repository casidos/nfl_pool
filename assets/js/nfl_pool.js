$(document).ready(function() {
  $('.select-pick').click(function() {
    var type = $(this).data('type');

    data = {
      odd_id: $(this).data('odd'),
      team_id: $(this).data('team')
    }
    data['_csrf'] = $("input[name='_csrf']").attr('value');

    $.ajax({
      method: 'POST',
      url: '/pick',
      data: data,
      context: this,
      success: function() {
        var klass = "#" + data['odd_id'] + " .select-pick";

        $(klass).removeClass("btn-success");
        $(klass).addClass("btn-default");

        $(this).removeClass("btn-default");
        $(this).addClass("btn-success");

        if (type === 'spread') {
          $(klass).html('<i class="fa fa-ban"></i>');
          $(this).html('<i class="fa fa-check"></i>');
        }
      },
      error: function(data) {
        alert('fucked');
        alert(data);
      }
    });
  });
});
