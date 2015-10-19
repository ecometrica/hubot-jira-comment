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

module.exports = (robot) ->
  robot.router.post '/hubot/chat-jira-comment/:room', (req, res) ->
    room = req.params.room
    body = req.body
    if body.webhookEvent == 'jira:issue_updated' && body.comment
      issue = "#{body.issue.key} #{body.issue.fields.summary}"
      url = "#{process.env.HUBOT_JIRA_URL}/browse/#{body.issue.key}"

      # Stop at first whitespace after COMMENT_LENGTH
      comment = body.comment.body
      first_whitespace = /\s/.exec(comment[COMMENT_LENGTH...])
      if first_whitespace?
        comment = comment[...(COMMENT_LENGTH + first_whitespace.index)] + " [...]"

      robot.messageRoom room, "#{body.comment.author.name} commented on *#{issue}* _(#{url})_\n>>>\n#{comment}"
    res.send 'OK'
