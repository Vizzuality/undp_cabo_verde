jQuery ->
  $(document).on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs').hide()
    event.preventDefault()

  $(document).on 'click', '.add_fields', (event) ->
    regexp = new RegExp($(this).data('id'))
    $(this).before($(this).data('fields').replace(regexp))
    event.preventDefault()
    showDatepicker()

  $(document).on 'click', '.add_actors_fields', (event) ->
    regexp = new RegExp($(this).data('id'))
    $('.add-relations').before($(this).data('fields').replace(regexp))
    event.preventDefault()
    current_actor = $('.current-actor-wrapper .current-actor')
    value = $('#actor_name').val()
    current_actor.text value 
    $('#actor_name').on 'keyup', (e)->
      current_actor.text e.currentTarget.value
      return
    showDatepicker()

  $(document).on 'click', '.switch_parent_form', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs-child').hide()
    $('.add_parent_actor').click()
    event.preventDefault()

  $(document).on 'click', '.switch_child_form', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs-parent').hide()
    $('.add_child_actor').click()
    event.preventDefault()

  relations = $('.relation_child_id, .relation_parent_id')
  relations.each ->
    el = $(@)
    if el.val() != ''
      el.closest('.form-inputs').find('.switch_child_form, .switch_parent_form').remove()
