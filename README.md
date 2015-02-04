# hubot-jira-spy
The missing Jira-Slack integration feature.

[Hubot](https://hubot.github.com/) hears your [Jira](https://www.atlassian.com/software/jira) events, chat comments to [Slack](https://slack.com/).


## Jira Setting
Add an WebHook on Setting > WebHooks menu.

Hook URL is `http://your-hubot-listener/hubot/chat-jira-comment/:room`

Make sure the `Issue Update` Events can be post.

![](https://raw.githubusercontent.com/mnpk/hubot-jira-spy/master/jira-setup.png)

## Hubot Setting
Add this script to your hubot-slack.

## Example Message on Slack

![](https://raw.githubusercontent.com/mnpk/hubot-jira-spy/master/jira-spy-example.png)