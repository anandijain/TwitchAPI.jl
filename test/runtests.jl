using HTTP, JSON, JSON3, CSV, DataFrames
include("keys.jl");
# `twitch api get users -q id=141981764`
# `twitch api get users -q login=slurpwaffl`
# twitch token -u -s chat:read -s chat:edit 
user_id = "218375180"
login = "slurpwaffl"



# r = response = HTTP.get(url, headers=headers)
headers = Dict("Client-ID" => client_id, "Authorization" => "Bearer $oauth_token")
url = "https://api.twitch.tv/helix/videos?user_id=$user_id"

j = JSON3.read(r.body)
vod_list = []

while true
    response = HTTP.get(url, headers=headers)

    if response.status != 200
        println("Error getting VODs.")
        break
    end

    data = JSON3.read(response.body)
    # @info data
    append!(vod_list, data["data"])

    if data["pagination"] != nothing && "cursor" in keys(data["pagination"])
        url = "https://api.twitch.tv/helix/videos?user_id=$user_id&after=$(data["pagination"]["cursor"])"
    else
        break
    end
end
println("Found $(length(vod_list)) VODs.")

df = ifelse.(df .== nothing, missing, df)
CSV.write("vods.csv", df)


println("Found $(length(vod_list)) VODs.")

# client_id = "YOUR_CLIENT_ID"
vod_id = "YOUR_VOD_ID"
vids = df.id
vod_id = vids[1]
comments = []
for vod_id in df.id
    headers = Dict("Client-ID" => client_id, "Authorization" => "OAuth $oauth_token");
    url = "https://api.twitch.tv/helix/videos/$vod_id/comments?cursor=0"


    while true
        response = HTTP.get(url, headers=headers);

        if response.status != 200
            println("Error getting comments.")
            break
        end

        data = JSON.parse(String(response.body))
        push!(comments, vod_id => data["comments"])

        if "_next" in data
            url = "https://api.twitch.tv/helix/videos/$vod_id/comments?cursor=$(data["_next"])"
        else
            break
        end
    end
end

println("Found $(length(comments)) comments.")
