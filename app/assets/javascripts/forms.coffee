jQuery ->
  $(document).on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs').hide()
    event.preventDefault()

  $(document).on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
    showDatepicker()

  $(document).on 'click', '.add_location', (event) ->
    $siblings = $(event.currentTarget).siblings('.form-inputs')
    map = $($siblings[$siblings.length - 1]).find('.map-preview')[0]
    initPreviewMap($siblings[$siblings.length - 1])

  cloneCount = 1

  $(document).on 'click', '.add_actors_fields, .add_actions_fields', (event) ->
    time       = new Date().getTime()
    regexp     = new RegExp($(this).data('id'), 'g')

    $(this).before($(this).data('fields').replace(regexp, time))

    event.preventDefault()
    current_actor_action = $('.current-actor-wrapper .current-actor, .current-action-wrapper .current-action')
    value = $('#actor_name, #act_name').val()
    current_actor_action.text value
    $('#actor_name, #act_name').on 'keyup', (e)->
      current_actor_action.text e.currentTarget.value
      return
    showDatepicker()

  $(document).on 'click', '.switch_parent_form', (event) ->
    time       = new Date().getTime()
    regexp     = new RegExp($('.add_parent_actor, .add_parent_action').data('id'), 'g')

    $(this).closest('.form-inputs-child')
      .html($('.add_parent_actor, .add_parent_action').data('fields').replace(regexp, time))
    event.preventDefault()
    current_actor_action = $('.current-actor-wrapper .current-actor, .current-action-wrapper .current-action')
    value = $('#actor_name, #act_name').val()
    current_actor_action.text value
    $('#actor_name, #act_name').on 'keyup', (e)->
      current_actor_action.text e.currentTarget.value
      return
    showDatepicker()

  $(document).on 'click', '.switch_child_form', (event) ->
    time       = new Date().getTime()
    regexp     = new RegExp($('.add_child_actor, .add_child_action').data('id'), 'g')

    $(this).closest('.form-inputs-parent')
      .html($('.add_child_actor, .add_child_action').data('fields').replace(regexp, time))
    event.preventDefault()
    current_actor_action = $('.current-actor-wrapper .current-actor, .current-action-wrapper .current-action')
    value = $('#actor_name, #act_name').val()
    current_actor_action.text value
    $('#actor_name, #act_name').on 'keyup', (e)->
      current_actor_action.text e.currentTarget.value
      return
    showDatepicker()

  relations = $('.relation_child_id, .relation_parent_id')
  relations.each ->
    el = $(@)
    if el.val() != ''
      el.closest('.form-inputs').find('.switch_child_form, .switch_parent_form').remove()

  $(document).on 'click', '.view-relation', (event) ->
    event.preventDefault()
    $('.relation-preview').show()
    $(this).closest('.relation-preview').hide()
    if $(this).data('type') == 'actor-actor-relation'
      $('.js-collapsable-actor').hide()
    $("#expanded-"+$(this).attr('id')).show()
