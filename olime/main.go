package main

import (
	"http"
	"bufio"
)
func main() {
	var client http.Client
	resp, err := client.Get("http://olime.baidu.com/py?rn=0&pn=20&py=nihao")
	if err != nil {
		panic("get err")
	}
	reader := bufio.NewReader(resp.Body)
	line, err := reader.ReadString('\n')
	// GBK encoding
	print(line)
}
