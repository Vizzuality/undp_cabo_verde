jQuery ->
  $(document).on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-inputs').hide()
    event.preventDefault()

  ## Clicking on the preview delete-button triggers the real delete event in the form
  $(document).on 'click', '.remove_fields_preview', (event) ->
    $(this).closest('.relation-preview').remove()
    pairID = $(this).data('delete-pair')
    $('#' + pairID).trigger('click')
    event.preventDefault()

  $(document).on 'click', '.remove_preview_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.relation-preview').hide()
    event.preventDefault()

  $(document).on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
    showDatepicker()
    addChosen()

  $(document).on 'click', '.add_act_relation_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
    current_indicator = $('.current-indicator-wrapper .current-indicator')
    value = $('#indicator_name').val()
    current_indicator.text value
    $('#indicator_name').on 'keyup', (e)->
      current_indicator.text e.currentTarget.value
      return
    showDatepicker()
    addChosen()

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
    addChosen()

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
    addChosen()

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
    addChosen()

  relations = $('.relation_child_id, .relation_parent_id')
  relations.each ->
    el = $(@)
    if el.val() != ''
      el.closest('.form-inputs').find('.switch_child_form, .switch_parent_form').remove()

  $(document).on 'click', '.view-relation', (event) ->
    event.preventDefault()
    $('.'+$(this).data('relation-type')).hide()
    parent = $(this).parents('.content.active')
    parent.find('.relation-preview').show()
    $(this).closest('.relation-preview').hide()
    $("#expanded-"+$(this).attr('id')).show()

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
    event.preventDefault()
    return

  $(document).on 'change', 'input.localization_main', (event) ->
    $('input.localization_main').not(this).prop('checked', false)

  addChosen = ->
    # enable chosen js
    $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      disable_search_threshold: 7
      placeholder_text_single: 'Select an Option'

  $(document).on 'ready', () ->
    addChosen()

  $('.tags-select').select2
    tags: true
    tokenSeparators: [',']
