xml.xml {
	xml.ToUserName {xml.cdata! @response[:to_user_name]}

	if not @response[:from_user_name].nil?
		xml.FromUserName do
			xml.cdata! @response[:from_user_name]
		end
	end

	xml.CreateTime(@response[:create_time])

	xml.MsgType do
		xml.cdata! @response[:msg_type]
	end

	if @response.is_text?
		xml.Content do
			xml.cdata! @response.content
		end
	end

	if @response.is_music?
		xml.Music {
			if @response.title.present?
				xml.Title do
					xml.cdata! @response.title
				end
			end

			if @response.introduction.present?
				xml.Description do
					xml.cdata! @response.introduction
				end
			end

			if @response.music_url.present?
				xml.MusicUrl do
					xml.cdata! @response.music_url
				end
			end

			if @response.hq_music_url.present?
				xml.HQMusicUrl do
					xml.cdata! @response.hq_music_url
				end
			end
		}
	end

	if @response.is_news?
		xml.ArticleCount @response.articles.length
		xml.Articles{
			@response.articles.each_with_index do |article, index|
				xml.item {
					if article.title.present?
						xml.Title do
							xml.cdata! article.title
						end
					end

					if article.introduction.present? or article.description.present?
						xml.Description do
							xml.cdata! article.introduction.presence || article.description
						end
					end

					if article.pic_url.present?
						xml.PicUrl do
							xml.cdata! article.pic_url.starts_with?("/") ? URI.join(root_url, article.pic_url).to_s : article.pic_url
						end
					end

					if article.url.present?
						xml.Url do
							xml.cdata! article.url.starts_with?("/") ? URI.join(root_url, article.url).to_s : article.url
						end
					end
				}
			end
		}
	end
}
