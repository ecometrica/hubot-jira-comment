# vim: set sw=2:
# Description:
#   Forward Jira comments to Slack.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JIRA_URL
#
# Commands:
#   None
#
# Author:
#   mnpk <mnncat@gmail.com>
COMMENT_LENGTH = 140

shortenText = (text) ->
    # Stop at first whitespace after COMMENT_LENGTH
    first_whitespace = /\s/.exec(text[COMMENT_LENGTH...])
    if first_whitespace?
      text = text[...(COMMENT_LENGTH + first_whitespace.index)] + " [...]"
    return text

class ParsedEvent
  constructor: (@body) ->

  issueCreated: () ->
    @body.webhookEvent == 'jira:issue_created'
  issueUpdated: () ->
    @body.comment && (@body.webhookEvent == 'jira:issue_updated')
  issueAssigned: () ->
    (@body.webhookEvent == 'jira:issue_updated') && (@firstChangelog()?.field == 'assignee')
  issueStatusChange: () ->
    (@body.webhookEvent == 'jira:issue_updated') && (@firstChangelog()?.field == 'status')
  issueDeleted: () -> @body.webhookEvent == 'jira:issue_deleted'

  firstChangelog: () ->
    @body.changelog?.items[0]

  issue: () -> "#{@body.issue.key} #{@body.issue.fields.summary}"
  url: () -> "#{process.env.HUBOT_JIRA_URL}/browse/#{@body.issue.key}"
  author: () -> @body.comment.author.name
  user: () -> @body.user.displayName

  transfer: () ->
    chlog = @firstChangelog()
    [chlog.fromString, chlog.toString]

  comment: () -> shortenText(@body.comment.body)
  description: () -> shortenText(@body.issue.fields.description || '')


module.exports = (robot) ->
  robot.router.post '/hubot/chat-jira-comment/:room', (req, res) ->
    room = req.params.room
    event = new ParsedEvent(req.body)

    # Use this to debug messages coming from jira, you should be able to read
    # the full object in the hubot log.
    #console.dir(req.body, {depth: null})

    if event.issueUpdated()
      robot.messageRoom room, "#{event.author()} commented on *#{event.issue()}* _(#{event.url()})_\n>>>\n#{event.comment()}"
    else if event.issueCreated()
      robot.messageRoom room, "#{event.user()} created *#{event.issue()}* _(#{event.url()})_\n>>>\n#{event.description()}"
    else if event.issueAssigned()
      [fromUser, toUser] = event.transfer()
      msg = ["#{event.user()} assigned *#{event.issue()}* _(#{event.url()})_"]

      if fromUser?
        msg.push("from #{fromUser}")
      if toUser?
        msg.push("to #{toUser}")
      robot.messageRoom(room, msg.join(" "))
    else if event.issueStatusChange()
      [fromStatus, toStatus] = event.transfer()
      robot.messageRoom room, "#{event.user()} moved *#{event.issue()}* _(#{event.url()})_ from #{fromStatus} to #{toStatus}"
    else if event.issueDeleted()
      robot.messageRoom room, "#{event.user()} deleted *#{event.issue()}* _(#{event.url()})_"


    res.send 'OK'
