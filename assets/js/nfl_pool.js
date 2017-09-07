var timer = null;

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
      url: '/picks',
      data: data,
      context: this,
      success: function(response) {
        var klass = "#" + data['odd_id'] + " .select-pick";

        $(klass).removeClass("btn-success");
        $(klass).addClass("btn-default");

        $(this).removeClass("btn-default");
        $(this).addClass("btn-success");

        if (type === 'spread') {
          $(klass).html('<i class="fa fa-ban"></i>');
          $(this).html('<i class="fa fa-check"></i>');
        }

        if (timer) {
          clearTimeout(timer)
        }
        $(".alert-fixed").remove();

        $("body").append('<div class="alert alert-dismissable alert-success alert-fixed"><button aria-hidden="true" data-dismiss="alert" class="close">×</button>Selection saved: ' + response +'</div>');

        timer = setTimeout(function() {
          $(".alert-fixed").remove();
        }, 3000);
      },
      error: function(response) {
        $(".alert-fixed").remove();
        alert('Uh oh, butt fumble. Contact your admin.');
      }
    });
  });
});
