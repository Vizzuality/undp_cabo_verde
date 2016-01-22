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

  $(document).on 'click', '.add_actors_fields, .add_actions_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $('.add-relations').before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
    current_actor_action = $('.current-actor-wrapper .current-actor, .current-action-wrapper .current-action')
    value = $('#actor_name, #act_name').val()
    current_actor_action.text value
    $('#actor_name, #act_name').on 'keyup', (e)->
      current_actor_action.text e.currentTarget.value
      return
    showDatepicker()

  $(document).on 'click', '.switch_parent_form', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs-child').hide()
    $('.add_parent_actor, .add_parent_action').click()
    event.preventDefault()

  $(document).on 'click', '.switch_child_form', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs-parent').hide()
    $('.add_child_actor, .add_child_action').click()
    event.preventDefault()

  relations = $('.relation_child_id, .relation_parent_id')
  relations.each ->
    el = $(@)
    if el.val() != ''
      el.closest('.form-inputs').find('.switch_child_form, .switch_parent_form').remove()

  $(document).on 'click', '.add_other_domain', (event) ->
    domains_form   = $('.form-inputs-other-domains:visible')
    domains_select = $('.domains-chose')
    if (domains_form.length == 2)
      $(this).hide()
    if (domains_select.val().length > 1)
      $(this).hide()
    event.preventDefault()

  $(document).on 'click', '.remove_domains', (event) ->
    $('.add_other_domain').show()
    return
    event.preventDefault()
