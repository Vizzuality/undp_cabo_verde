jQuery ->
  $(document).on 'click', '.remove-favourite', (event) ->
    event.preventDefault()
    $(this).closest('.table-row.favourite-row').remove()
