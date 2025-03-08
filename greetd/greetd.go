package greetd

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"net"
	"os"
)

var ErrAuthError = fmt.Errorf("authentication error")

type Request struct {
	Type     string   `json:"type"`
	Response string   `json:"response,omitempty"`
	Username string   `json:"username,omitempty"`
	Cmd      []string `json:"cmd,omitempty"`
	Env      []string `json:"env,omitempty"`
}
type Responce struct {
	Type            string `json:"type"`
	ErrorType       string `json:"error_type,omitempty"` // auth_error, error
	Description     string `json:"description,omitempty"`
	AuthMessage     string `json:"auth_message,omitempty"`
	AuthMessageType string `json:"auth_message_type,omitempty"` // visible, secret, info, error
}

func fetch(conn net.Conn) (*Responce, error) {
	var length int32
	binary.Read(conn, binary.NativeEndian, &length)
	data := make([]byte, length)
	_, err := conn.Read(data)
	if err != nil {
		return nil, err
	}
	resp := Responce{}
	err = json.Unmarshal(data, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}
func request(conn net.Conn, req Request) error {
	data, err := json.Marshal(&req)
	if err != nil {
		return err
	}
	err = binary.Write(conn, binary.NativeEndian, int32(len(data)))
	if err != nil {
		return err
	}
	err = binary.Write(conn, binary.NativeEndian, data)
	if err != nil {
		return err
	}
	return nil
}
func send(req Request) (*Responce, error) {
	sock, ok := os.LookupEnv("GREETD_SOCK")
	if !ok {
		return nil, fmt.Errorf("GREETD_SOCK not found")
	}
	conn, err := net.Dial("unix", sock)
	if err != nil {
		return nil, err
	}
	defer conn.Close()
	err = request(conn, req)
	if err != nil {
		return nil, err
	}
	return fetch(conn)
}
func createSession(username string) error {
	req := Request{
		Type:     "create_session",
		Username: username,
	}
	resp, err := send(req)
	if err != nil {
		return err
	}
	if resp.Type == "error" {
		return fmt.Errorf("failed to create session: %s", resp.Description)
	}
	return nil
}
func postAuthMessageResponse(response string) error {
	req := Request{
		Type:     "post_auth_message_response",
		Response: response,
	}
	resp, err := send(req)
	if err != nil {
		return err
	}
	if resp.Type == "error" {
		if resp.ErrorType == "auth_error" {
			return fmt.Errorf("%w: %s", ErrAuthError, resp.Description)
		}
		return fmt.Errorf("failed to post auth message response: %s", resp.Description)
	}
	return nil
}
func startSession(cmd []string, env []string) error {
	req := Request{
		Type: "start_session",
		Cmd:  cmd,
		Env:  env,
	}
	resp, err := send(req)
	if err != nil {
		return err
	}
	if resp.Type == "error" {
		return fmt.Errorf("failed to start session: %s", resp.Description)
	}
	return nil
}
func cancelSession() error {
	req := Request{
		Type: "cancel_session",
	}
	resp, err := send(req)
	if err != nil {
		return err
	}
	if resp.Type == "error" {
		return fmt.Errorf("failed to cancel session: %s", resp.Description)
	}
	return nil
}

func Login(username, password string, cmd, env []string) error {
	if password == "" {
		return fmt.Errorf("password cannot be empty")
	}
	var err error
	defer func() {
		if err != nil {
			cancelSession()
			fmt.Println("Error:", err)
		}
	}()
	err = createSession(username)
	if err != nil {
		return err
	}
	err = postAuthMessageResponse(password)
	if err != nil {
		return err
	}
	err = startSession(cmd, env)
	if err != nil {
		return err
	}
	return nil
}
