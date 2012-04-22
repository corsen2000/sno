jQuery ->
    $("#search").autocomplete {
        source: searchIndex
        autoFocus: true
        delay: 0
        focus: (event, ui) ->
            if /^(key)/.test(event.originalEvent.originalEvent.type)
                $("#search").val(ui.item.display)
            false
        select: (event, ui) ->
            window.location.href = ui.item.value
            false
        }