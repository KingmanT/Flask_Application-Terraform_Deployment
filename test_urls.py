import json

def test_url():
    file = open('urls.json')
    data = json.load(file)
    test = data['go']['url']
    assert test == "http://google.com"

# x = url_test()