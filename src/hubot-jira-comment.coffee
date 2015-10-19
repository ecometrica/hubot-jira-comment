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

module.exports = (robot) ->
  robot.router.post '/hubot/chat-jira-comment/:room', (req, res) ->
    room = req.params.room
    body = req.body
    if body.webhookEvent == 'jira:issue_updated' && body.comment
      issue = "#{body.issue.key}: #{body.issue.fields.summary}"
      url = "#{process.env.HUBOT_JIRA_URL}/browse/#{body.issue.key}"
      if body.comment.body.length > 140
        comment = body.comment.body[0...140] + "[...]\nRead more: _(#{url})_"
      else
        comment = body.comment.body
      robot.messageRoom room, "*#{issue}* _(#{url})_\n@#{body.comment.author.name}'s comment:\n>>>#{comment}"
    res.send 'OK'

